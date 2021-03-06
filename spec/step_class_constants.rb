module StepClassConstants
  def base_step_class
    InkStep::Base
  end

  # utility steps

  def zip_step_class
    InkStep::UtilitySteps::ZipStep
  end

  def unzip_step_class
    InkStep::UtilitySteps::UnzipStep
  end

  def modified_files_step_class
    InkStep::UtilitySteps::ModifiedFileCollectorStep
  end

  def conversion_step_class
    InkStep::ConversionStep
  end

  def rot_thirteen_step_class
    InkStep::Coko::RotThirteenStep
  end

  def shoutifier_step_class
    InkStep::Coko::ShoutifierStep
  end

  def epub_calibre_step_class
    InkStep::Coko::CalibreHtmlToEpubStep
  end

  def pandoc_docx_to_html_step_class
    InkStep::Coko::PandocDocxToHtmlStep
  end

  def pandoc_epub_to_icml_step_class
    InkStep::Coko::PandocEpubToIcmlStep
  end

  def calibre_html_to_epub_step_class
    InkStep::Coko::CalibreHtmlToEpubStep
  end

  def pandoc_conversion_step_class
    InkStep::Coko::PandocConversionStep
  end

  # xsweet pipeline

  def xsweet_step_1_extract_step_class
    InkStep::Coko::XsweetPipeline::DocxExtract::DocxToHtmlExtractStep
  end

  def xsweet_step_2_notes_step_class
    InkStep::Coko::XsweetPipeline::DocxExtract::HandleNotesStep
  end

  def xsweet_step_3_scrub_step_class
    InkStep::Coko::XsweetPipeline::DocxExtract::ScrubStep
  end

  def xsweet_step_4_join_step_class
    InkStep::Coko::XsweetPipeline::DocxExtract::JoinElementsStep
  end

  def xsweet_step_5_collapse_paragraphs_step_class
    InkStep::Coko::XsweetPipeline::DocxExtract::CollapseParagraphsStep
  end

  def xsweet_step_6_handle_lists_step_class
    InkStep::Coko::XsweetPipeline::HandleLists::HandleListsStep
  end

  def xsweet_step_7_header_promotion_step_class
    InkStep::Coko::XsweetPipeline::HeaderPromote::HeaderPromotionStep
  end

  def xsweet_step_8_final_rinse_step_class
    InkStep::Coko::XsweetPipeline::FinaliseTypescript::FinalRinseStep
  end

  def xsweet_step_9_editoria_step_class
    InkStep::Coko::XsweetPipeline::PrepareForEditoria::EditoriaPrepareStep
  end

end