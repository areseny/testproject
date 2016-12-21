module StepClassConstants
  def base_step_class
    InkStep::Base
  end

  def conversion_step_class
    InkStep::ConversionStep
  end

  def rot_thirteen_step_class
    InkStep::RotThirteenStep
  end

  def shoutifier_step_class
    InkStep::ShoutifierStep
  end

  def epub_calibre_step_class
    InkStep::CalibreToEpubStep
  end

  def pandoc_to_html_step_class
    InkStep::PandocToHtmlStep
  end

  # xsweet pipeline

  def xsweet_step_1_extract_step_class
    InkStep::XsweetPipeline::DocxToHtmlExtractStep
  end

  def xsweet_step_2_notes_step_class
    InkStep::XsweetPipeline::HandleNotesStep
  end

  def xsweet_step_3_scrub_step_class
    InkStep::XsweetPipeline::ScrubStep
  end

  def xsweet_step_4_join_step_class
    InkStep::XsweetPipeline::JoinElementsStep
  end

  def xsweet_step_5_zorba_step_class
    InkStep::XsweetPipeline::ZorbaMapStep
  end
end