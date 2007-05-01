########################################################
# This example shows how to build custom PDF output
# with Ruport that shares some common elements 
# between reports.  Basically, CompanyPDFBase implements
# some default rendering options, and derived classes
# such as ClientPDF would implement the stuff specific
# to a given report.
########################################################

require "active_support"
require "ruport"

# This looks a little more messy than usual, but it addresses your
# concern of wanting to have a standard template.
#
class ClientRenderer < Ruport::Renderer
 prepare :standard_report
 stage :company_header, :client_header, :client_body, :client_footer
 finalize :standard_report
 option :example

 def setup
    # replace this with your header changing code
    data.rename_columns { |c| c.to_s.titleize }
    # this just lets us omit the options prefix in the formatter
    formatter.class.opt_reader(:example)
 end
end

# This defines your base PDF output, you'd do similar for other
# formats if needed It doesn't do much of anything except 
# implement the common hooks
class CompanyPDFBase < Ruport::Formatter::PDF
 def prepare_standard_report
    options.paper_size = "A4"
 end

 def build_company_header
    add_text "This would be my company header",
             :justification => :center, :font_size => 14
 end

 def finalize_standard_report
   render_pdf
 end
end

#  This is your report's formatter
#
#  It implements the remaining hooks the standard formatter didn't
#  Notice I left out a footer and it didn't complain. 
class ClientPDF < CompanyPDFBase
 renders :pdf, :for => ClientRenderer

 def build_client_header
   pad(10) do
    add_text "Specific Report Header with option #{example}",
             :justification => :center, :font_size => 12
   end
 end

 def build_client_body
    draw_table(data, :width => 300)
 end

end


table = Table([:a,:b,:c]) << [1,2,3] << [4,5,6]
File.open("example.pdf","w") { |f|
 f << ClientRenderer.render_pdf(:data => table,:example => "foo")
}