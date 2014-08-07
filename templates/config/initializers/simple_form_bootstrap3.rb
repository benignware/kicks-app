inputs = %w[
  CollectionSelectInput
  FileInput
  GroupedCollectionSelectInput
  NumericInput
  PasswordInput
  RangeInput
  StringInput
  TextInput
]
inputs.each do |input_type|
  superclass = "SimpleForm::Inputs::#{input_type}".constantize
  new_class = Class.new(superclass) do
    def input_html_classes
      super.push('form-control')
    end
  end
  Object.const_set(input_type, new_class)
end
SimpleForm.setup do |config|
  
  config.boolean_style = :nested
  config.button_class = 'btn btn-default'
  config.error_notification_class = 'alert alert-danger'
  
  config.wrappers :bootstrap3, tag: 'div', class: 'form-group', error_class: 'has-error',
      defaults: { input_html: { class: 'default_class' } } do |b|
    
    b.use :html5
    b.use :min_max
    b.use :maxlength
    b.use :placeholder
    
    b.optional :pattern
    b.optional :readonly
    
    b.use :label_input
    b.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
    b.use :error, wrap_with: { tag: 'span', class: 'help-block has-error' }
  end
 
  config.default_wrapper = :bootstrap3
end

