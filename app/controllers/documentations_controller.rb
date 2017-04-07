class DocumentationsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_markdown_parser

  def index
    @collection = Documentation.roots
  end

  def show
    @documentation = Documentation.find(params[:id])
  end

  def current_module
    'documentation'
  end

  def load_markdown_parser
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
  end
end
