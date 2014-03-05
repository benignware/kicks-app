class FileInput < SimpleForm::Inputs::FileInput
  def input
    @builder.file_field(attribute_name, input_html_options)
  end
end