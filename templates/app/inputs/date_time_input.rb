class DateTimeInput < SimpleForm::Inputs::Base
  def input
 
    input_html_options[:type] ||= input_type if html5?
    
    case input_type
      when :date
        @builder.text_field(attribute_name, {class: 'datetimepicker form-control', autocomplete: 'off', type: 'date', value: @builder.object[attribute_name] ? @builder.object[attribute_name].strftime("%Y-%m-%d") : "", data: {format: 'YYYY-MM-DD', pickTime: 'false'}})
        #template.content_tag(:div, @builder.text_field(attribute_name, class: 'datepicker form-control', data: {format: 'yy-mm-dd'}) << template.content_tag(:span, template.content_tag(:i, "", class: "glyphicon glyphicon-calendar"), class: 'input-group-addon add-on btn') , class: 'input-group')
        #template.content_tag(:div, template.content_tag(:span, template.content_tag(:i, "", class: "glyphicon glyphicon-calendar"), class: 'input-group-addon add-on btn') << @builder.text_field(attribute_name, class: 'form-control', data: {format: 'YYYY-DD-MM'}), class: "datetimepicker input-group")
      when :datetime
        #template.content_tag(:div, template.content_tag(:span, template.content_tag(:i, "", class: "glyphicon glyphicon-calendar"), class: 'input-group-addon add-on btn') << @builder.text_field(attribute_name, class: 'form-control', data: {format: 'YYYY-DD-MM HH:mm'}), class: "datetimepicker input-group")
        @builder.date_field(attribute_name, {class: 'datetimepicker form-control', type: 'datetime', value: @builder.object[attribute_name] ? @builder.object[attribute_name].strftime("%Y-%m-%dT%H:%M:%SZ") : "", data: {format: 'YYYY-MM-DD HH:mm'}})
      when :time
        #@builder.text_field(attribute_name, class: 'timepicker form-control', data: {format: 'HH:MM'})
        #template.content_tag(:div, template.content_tag(:span, template.content_tag(:i, "", class: "glyphicon glyphicon-time"), class: 'input-group-addon add-on btn') << @builder.text_field(attribute_name, class: 'timepicker form-control'), class: 'input-group')
        #template.content_tag(:div, template.content_tag(:span, template.content_tag(:i, "", class: "glyphicon glyphicon-time"), class: 'input-group-addon add-on btn') << @builder.text_field(attribute_name, class: 'form-control', data: {format: 'HH:mm'}), class: "datetimepicker input-group")
        @builder.text_field(attribute_name, {class: 'datetimepicker form-control', value: @builder.object[attribute_name] ? @builder.object[attribute_name].strftime("%H:%M") : "", data: {format: 'HH:mm', pickDate: 'false'}})
    end
  end
end