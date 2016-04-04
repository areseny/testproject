require 'rails_helper'

describe "User creates recipe" do

  # URL: /api/recipes
  # Method: POST
  # Use this route to end the user's current session. This route will invalidate the user's authentication token.

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: user@example.com, auth_token: asdf" -X POST http://localhost:3000/api/recipes

  describe "POST create new recipe" do

    let!(:user)             { FactoryGirl.create(:user, password: "password", password_confirmation: "password") }
    let!(:name)             { "My Splendiferous PNG to JPG transmogrifier" }
    let!(:description)      { "It transmogrifies! It transforms! It even goes across filetypes!" }
    let!(:auth_headers)     { user.create_new_auth_token }

    let!(:recipe_params) {
      {
          recipe: {
              name: name,
              description: description,
              uid: user.email
          }
      }
    }

    context 'if user is signed in' do

      context 'and the user provides no step data' do
        before do
          perform_create_request(auth_headers, recipe_params)
        end

        it 'responds with success' do
          expect(response.status).to eq(200)
        end

        it 'should return a Recipe object' do
          expect(body_as_json['name']).to eq name
          expect(body_as_json['description']).to eq description
          expect(body_as_json['active']).to eq true
        end

        it 'should create a new recipe with the parameters' do
          expect(user.reload.recipes.count).to eq 1

          recipe = user.recipes.first
          expect(recipe.user).to eq user
          expect(recipe.name).to eq name
          expect(recipe.description).to eq description
          expect(recipe.active).to be_truthy
        end
      end

      context 'if there are steps supplied' do

        let!(:docx_to_xml)      { FactoryGirl.create(:step_class, name: "DocxToXml") }
        let!(:xml_to_html)      { FactoryGirl.create(:step_class, name: "XmlToHtml") }

        context 'presented as a series of steps with positions included' do
          let!(:step_params)      { [{position: 1, name: "DocxToXml"}, {position: 2, name: "XmlToHtml" }] }

          context 'and they are valid' do
            before do
              recipe_params[:steps_with_positions] = step_params
            end

            it "should create the recipe with step templates" do
              perform_create_request(user.create_new_auth_token, recipe_params)

              expect(response.status).to eq 200
              new_recipe = user.recipes.first
              expect(new_recipe.step_templates.count).to eq 2
              expect(new_recipe.step_templates.sort_by(&:position).map(&:step_class_id)).to eq [docx_to_xml.id, xml_to_html.id]
            end
          end

          context 'and they are incorrect' do

            it "should not create the recipe for nonexistent step classes" do
              docx_to_xml.destroy
              recipe_params[:steps_with_positions] = [{position: 1, name: "DocxToXml"}, {position: 1, name: "XmlToHtml" }]
              perform_create_request(user.create_new_auth_token, recipe_params.to_json)

              expect(response.status).to eq 422
            end

            it "should not create the recipe with duplicate numbers" do
              recipe_params[:steps_with_positions] = [{position: 1, name: "DocxToXml"}, {position: 1, name: "XmlToHtml" }]
              perform_create_request(user.create_new_auth_token, recipe_params)

              expect(response.status).to eq 422
            end

            it "should not create the recipe with incorrect numbers" do
              recipe_params[:steps_with_positions] = [{position: 0, name: "DocxToXml"}, {position: 1, name: "XmlToHtml" }]
              perform_create_request(user.create_new_auth_token, recipe_params)

              expect(response.status).to eq 422
            end

            it "should not create the recipe with skipped steps" do
              recipe_params[:steps_with_positions] = [{position: 1, name: "DocxToXml"}, {position: 6, name: "XmlToHtml" }]
              perform_create_request(user.create_new_auth_token, recipe_params)

              expect(response.status).to eq 422
            end

            it "should create the recipe with numbers out of order" do
              recipe_params[:steps_with_positions] = [{position: 2, name: "XmlToHtml" }, {position: 1, name: "DocxToXml"}]
              perform_create_request(user.create_new_auth_token, recipe_params)

              expect(response.status).to eq 200
              new_recipe = user.recipes.first
              expect(new_recipe.step_templates.count).to eq 2
              expect(new_recipe.step_templates.sort_by(&:position).map(&:step_class_id)).to eq [docx_to_xml.id, xml_to_html.id]
            end
          end
        end

        context 'presented as a series of steps with order implicit' do
          context 'and they are valid' do
            before do
              recipe_params[:steps] = ["DocxToXml", "XmlToHtml"]
            end

            it "should create the recipe with step templates" do
              perform_create_request(user.create_new_auth_token, recipe_params)

              expect(response.status).to eq 200
              new_recipe = user.recipes.first
              expect(new_recipe.step_templates.count).to eq 2
              expect(new_recipe.step_templates.sort_by(&:position).map(&:step_class_id)).to eq [docx_to_xml.id, xml_to_html.id]
            end
          end

          context 'and they are incorrect' do

            it "should not create the recipe for nonexistent step classes" do
              docx_to_xml.destroy
              recipe_params[:steps] = ["DocxToXml", "XmlToHtml"]
              perform_create_request(user.create_new_auth_token, recipe_params)

              expect(response.status).to eq 422
            end
          end
        end
      end


    end

    context 'if no user is signed in' do
      before do
        perform_create_request({}, recipe_params)
      end

      it 'should raise an error' do
        expect(response.status).to eq(401)
      end

      it 'should provide a message' do
        expect_to_contain_string(body_as_json['errors'], /Authorized users only/)
      end
    end

    context 'if the token has expired' do
      before do
        expire_token(user, auth_headers['client'])
        perform_create_request({}, recipe_params)
      end

      it 'should raise an error' do
        expect(response.status).to eq(401)
      end

      it 'should provide a message' do
        expect_to_contain_string(body_as_json['errors'], /Authorized users only/)
      end
    end

  end
  
  def perform_create_request(auth_headers, data)
    create_recipe_request('v1', auth_headers, data.to_json)
  end
end