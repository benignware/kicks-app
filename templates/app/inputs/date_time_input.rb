class DateTimeInput < SimpleForm::Inputs::Base
  def input
 
    input_html_options[:type] ||= input_type if html5?
    
    case input_type
      when :date
        @builder.text_field(attribute_name, {class: 'datetimepicker form-control', autocomplete: 'off', value: @builder.object && @builder.object[attribute_name] ? @builder.object[attribute_name].strftime("%Y-%m-%dT%H:%M") : "", data: {date_format: 'YYYY-MM-DD', date_pickTime: false}})
      when :datetime
        @builder.date_field(attribute_name, {class: 'datetimepicker form-control', value: @builder.object[attribute_name] ? @builder.object[attribute_name].strftime("%Y-%m-%dT%H:%M") : "", data: {date_format: 'YYYY-MM-DD HH:mm'}})
      when :time
        @builder.text_field(attribute_name, {class: 'datetimepicker form-control', value: @builder.object[attribute_name] ? @builder.object[attribute_name].strftime("%Y-%m-%dT%H:%M") : "", data: {date_format: 'HH:mm', date_pickDate: false}})
    end
    
  end
end