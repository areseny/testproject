require 'rails_helper'
require_relative '../version'

describe "Account sets and unsets recipe as a favourite" do

  # URL: /api/recipe/:id
  # Method: GET
  # Use this route to mark a recipe as a favourite

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: account@example.com, auth_token: asdf" -X GET http://localhost:3000/api/recipes/:id/favourite

  describe "GET favourite" do

    let!(:account)          { create(:account, password: "password", password_confirmation: "password") }
    let!(:auth_headers)     { account.new_jwt }

    let!(:recipe)         { create(:recipe, account: account) }

    context 'if account is signed in' do
      context 'and the recipe exists' do
        context 'and it belongs to the account' do
          it 'responds with success' do
            perform_favourite_request(auth_headers, recipe.id)

            expect(response.status).to eq(200)
          end

          context 'and it is not favourited yet by that account' do
            specify do
              perform_favourite_request(auth_headers, recipe.id)

              expect(body_as_json['favourite']).to be_truthy
            end
          end

          context 'and has been favourited by that account' do
            before do
              create(:recipe_favourite, account: account, recipe: recipe)
            end

            specify do
              perform_favourite_request(auth_headers, recipe.id)

              expect(body_as_json['favourite']).to be_truthy
            end
          end
        end

        context 'and it belongs to a different account' do
          let!(:other_account)     { create(:account) }

          before do
            recipe.update_attribute(:account_id, other_account.id)
          end

          context 'and it is private' do
            before do
              recipe.update_attribute(:public, false)
            end

            it 'responds with failure' do
              perform_favourite_request(auth_headers, recipe.id)

              expect(response.status).to eq(404)
              expect(recipe.reload.favourited_by?(account)).to be_falsey
            end
          end

          context 'and it is public' do
            before do
              recipe.update_attribute(:public, true)
            end

            context 'and it is not favourited yet by that account' do
              specify do
                expect(recipe.reload.favourited_by?(account)).to be_falsey

                perform_favourite_request(auth_headers, recipe.id)

                expect(body_as_json['favourite']).to be_truthy
              end
            end

            context 'and has been favourited by that account' do
              before do
                create(:recipe_favourite, account: account, recipe: recipe)
              end

              specify do
                expect(recipe.reload.favourited_by?(account)).to be_truthy

                perform_favourite_request(auth_headers, recipe.id)

                expect(body_as_json['favourite']).to be_truthy
              end
            end
          end
        end
      end

      context 'and the recipe does not exist' do

        before do
          recipe.destroy
          perform_favourite_request(auth_headers, "rubbish")
        end

        it 'responds with failure' do
          expect(response.status).to eq(404)
        end
      end
    end

    context 'if no account is signed in' do
      before do
        perform_favourite_request({}, recipe.id)
      end

      it 'raises an error' do
        expect(response.status).to eq(401)
      end

      it 'provides a message' do
        expect_to_contain_string(body_as_json['errors'], /Authorized users only/)
      end
    end
  end
  # URL: /api/recipe/:id
  # Method: GET
  # Use this route to mark a recipe as a favourite

  # curl -H "Content-Type: application/json, Accept: application/vnd.ink.v1, uid: account@example.com, auth_token: asdf" -X GET http://localhost:3000/api/recipes/:id/favourite

  describe "GET favourite" do

    let!(:account)          { create(:account, password: "password", password_confirmation: "password") }
    let!(:auth_headers)     { account.new_jwt }

    let!(:recipe)         { create(:recipe, account: account) }

    context 'if account is signed in' do
      context 'and the recipe exists' do

        context 'and it belongs to the account' do
          it 'responds with success' do
            perform_unfavourite_request(auth_headers, recipe.id)

            expect(response.status).to eq(200)
          end

          context 'and it is not favourited yet by that account' do
            specify do
              perform_unfavourite_request(auth_headers, recipe.id)

              expect(body_as_json['favourite']).to be_falsey
            end
          end

          context 'and has been favourited by that account' do
            before do
              create(:recipe_favourite, account: account, recipe: recipe)
            end

            specify do
              perform_unfavourite_request(auth_headers, recipe.id)

              expect(body_as_json['favourite']).to be_falsey
            end
          end
        end

        context 'and it belongs to a different account' do
          let!(:other_account)     { create(:account) }

          before do
            recipe.update_attribute(:account_id, other_account.id)
          end

          context 'and it is private' do
            before do
              recipe.update_attribute(:public, false)
            end

            it 'responds with failure' do
              perform_unfavourite_request(auth_headers, recipe.id)

              expect(response.status).to eq(404)
            end
          end

          context 'and it is public' do
            before do
              recipe.update_attribute(:public, true)
            end

            context 'and it is not favourited yet by that account' do
              specify do
                expect(recipe.reload.favourited_by?(account)).to be_falsey

                perform_unfavourite_request(auth_headers, recipe.id)

                expect(body_as_json['favourite']).to be_falsey
              end
            end

            context 'and has been favourited by that account' do
              before do
                create(:recipe_favourite, account: account, recipe: recipe)
              end

              specify do
                expect(recipe.reload.favourited_by?(account)).to be_truthy

                perform_unfavourite_request(auth_headers, recipe.id)

                expect(body_as_json['favourite']).to be_falsey
              end
            end
          end
        end
      end

      context 'and the recipe does not exist' do

        before do
          recipe.destroy
          perform_unfavourite_request(auth_headers, "rubbish")
        end

        it 'responds with failure' do
          expect(response.status).to eq(404)
        end
      end
    end

    context 'if no account is signed in' do
      before do
        perform_unfavourite_request({}, recipe.id)
      end

      it 'raises an error' do
        expect(response.status).to eq(401)
      end

      it 'provides a message' do
        expect_to_contain_string(body_as_json['errors'], /Authorized users only/)
      end
    end
  end
  
  def perform_favourite_request(auth_headers, id)
    favourite_recipe_request(version, auth_headers, id)
  end

  def perform_unfavourite_request(auth_headers, id)
    unfavourite_recipe_request(version, auth_headers, id)
  end
end