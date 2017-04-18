class StepClassCollector

  def self.step_class_hash
    step_classes.map{|klass| { name: klass.name, description: klass.description } }
  end

  def self.step_classes
    # get all directories under gems that match ink_step
    # grab all the class names under those directories
    # minus Engine, minus Base

    # Dir.glob('/path/to/namespaced/directory/*').collect{|file_path| File.basename(file_path, '.rb').constantize}

    # require 'pathname'

    # make this the directory you are autoloading from
    # autoload_dir = File.join(Rails.application.root, 'app', 'models')

    # this will return FooBar::BarFoo::**::*Boo constants and autoload them
    # Dir.glob(File.join(autoload_dir, 'foo_bar', 'bar_foo', '**', '*_boo.rb')).collect{|pathname| Pathname.new(pathname.chomp('.rb')).relative_path_from(Pathname.new(autoload_dir)).to_s.camelize.constantize}

    # OR could do?
    # Dir["app/models/foo/*.rb"].each {|file| load file}

    classes = [
        InkStep::ShoutifierStep,
        InkStep::RotThirteenStep,
        InkStep::CalibreHtmlToEpubStep,
        InkStep::VivliostyleHtmlToPdfStep,
        InkStep::PandocEpubToIcmlStep,
        InkStep::WkHtmlToPdfStep,
        InkStep::PandocDocxToHtmlStep,
        InkStep::XsweetPipeline::DocxExtract::DocxToHtmlExtractStep,
        InkStep::XsweetPipeline::DocxExtract::HandleNotesStep,
        InkStep::XsweetPipeline::DocxExtract::JoinElementsStep,
        InkStep::XsweetPipeline::DocxExtract::ScrubStep,
        InkStep::XsweetPipeline::DocxExtract::CollapseParagraphsStep,
        InkStep::XsweetPipeline::HeaderPromote::HeaderPromotionStep,
        InkStep::XsweetPipeline::FinaliseTypescript::FinalRinseStep,
        InkStep::XsweetPipeline::PrepareForEditoria::EditoriaPrepareStep
    ].uniq
  end

end