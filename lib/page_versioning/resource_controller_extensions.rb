module PageVersioning::ResourceControllerExtensions
  def self.included(base)
    base.class_eval do      
      
      def update_with_preview
        # 'preview' param exists only if user presses "Preview Page" button
        if params[:preview]
          # We don't need to publish preview.
          model.update_attributes!(params[model_symbol])
          
          request_attributes = { :id => model.id, :action => model_symbol }
          request_attributes[:page_to_preview] = params[:page_to_preview] if params[:page_to_preview]
          redirect_to preview_url(request_attributes) and return
        else
          update_without_preview
        end
      end
      
      alias_method_chain :update, :preview
      
      
      protected
      
        # After executing of the edit action, set proper revision number if it was passed
        def render(*args)
          if request.path_parameters['action'] == "edit" && params[:revision]
            # Change revision number if given revision is not existed and we have set last revision
            params[:revision] = model.set_to_revision(params[:revision])
          end
          super(*args)
        end
      
    end
  end
end