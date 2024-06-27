# frozen_string_literal: true

class AdminRichTextAreaInput < Formtastic::Inputs::TextInput
  def to_html
    input_wrapping do
      editor_tag_params = {
              input: input_html_options[:id],
              class: "trix-content"
      }
      editor_tag = template.content_tag("trix-editor", "", editor_tag_params)
      hidden_field = builder.hidden_field(method, input_html_options)
      label_html + hidden_field + editor_tag
    end
  end
end
