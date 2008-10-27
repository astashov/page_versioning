module PageVersioning::AbstractModelControllerExtensions
  def self.included(base)
    base.class_eval do      
      
      def edit_with_preview
        # 'preview' param exists only if user presses "Preview Page" button
        if params[:preview]
          # Don't use published_revision_number because we don't need to publish preview.
          instance_variable_set("@#{model_symbol}", model_class.find(params[:id]))
          params[model_symbol.to_s][:published_revision_number] = model.published_revision_number
          model.is_preview = true

          # Saving...
          unless handle_preview_post
            request_attributes = { :id => model.id, :action => model.klass }
            request_attributes[:page_to_preview] = params[:page_to_preview] if params[:page_to_preview]
            redirect_to preview_url(request_attributes) and return
          else
            # If there are any errors...
            render :action => 'edit' and return
          end
        else
          edit_without_preview
        end
      end
      
      alias_method_chain :edit, :preview
      
      
      protected
      
        # After executing of the edit action, set proper revision number if it was passed
        def render(*args)
          if request.path_parameters['action'] == "edit" && params[:revision]
            model.set_to_revision(params[:revision])
          end
          super(*args)
        end
      
        def handle_preview_post(options = {})
          options.symbolize_keys
          if request.post?
            model.attributes = params[model_symbol]
            begin
              if save
                clear_model_cache
                return false
              else
                announce_validation_errors
              end
            rescue ActiveRecord::StaleObjectError
              announce_update_conflict
            end
          end
          true
        end
      
    end
  end
end