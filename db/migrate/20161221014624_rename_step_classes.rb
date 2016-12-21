class RenameStepClasses < ActiveRecord::Migration[5.0]
  def change
    ProcessStep.all.each do |step|
      step.update_attribute(:step_class_name, NAME_CHANGES[step.step_class_name].to_s)
    end

    RecipeStep.all.each do |step|
      step.update_attribute(:step_class_name, NAME_CHANGES[step.step_class_name].to_s)
    end
  end

  NAME_CHANGES = {
    "DocxToHtmlPandocStep" => InkStep::PandocToHtmlStep,
    "WkHtmlToPdfStep" => InkStep::WkHtmlToPdfStep,
    "VivliostyleToPdfStep" => InkStep::VivliostyleToPdfStep,
    "XsweetPipeline::DocxToHtmlExtractStep" => InkStep::XsweetPipeline::DocxToHtmlExtractStep,
    "XsweetPipeline::HandleNotesStep" => InkStep::XsweetPipeline::HandleNotesStep,
    "XsweetPipeline::ScrubStep" => InkStep::XsweetPipeline::ScrubStep,
    "XsweetPipeline::JoinElementsStep" => InkStep::XsweetPipeline::JoinElementsStep,
    "XsweetPipeline::ZorbaMapStep" => InkStep::XsweetPipeline::ZorbaMapStep,
    "RotThirteenStep" => InkStep::RotThirteenStep,
    "EpubCalibreStep" => InkStep::CalibreToEpubStep
  }
end
