module PageVersioning::PageControllerExtensions
  
  def self.included(base)
    base.class_eval do
      # alias_method_chain defined in abstract_model_controller_extensions doesn't work
      # for PageController, we should define it explicitly here.
      alias_method_chain :edit, :preview
    end
  end

end