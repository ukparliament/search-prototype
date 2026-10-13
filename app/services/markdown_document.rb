class MarkdownDocument
  attr_reader :document_path, :headings, :alphabetised_headings

  def initialize(document_path)
    @document_path = document_path
    @document = Commonmarker.parse(markdown_file)
    @headings = extract_headings
    @alphabetised_headings = alphabetise_headings
  end

  def markdown_file
    File.read(Rails.root.join(document_path))
  end

  def html
    Commonmarker.to_html(markdown_file).html_safe
  end

  private

  def alphabetise_headings
    extract_headings.group_by(&:first)
  end

  def extract_headings
    headings = []

    @document.walk do |node|
      next unless node.type == :heading

      headings << heading_text(node)
    end

    headings
  end

  def heading_text(heading)
    text = +""

    heading.walk do |node|
      text << node.string_content if node.type == :text
    end

    text
  end
end