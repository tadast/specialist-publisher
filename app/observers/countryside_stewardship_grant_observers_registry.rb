require "formatters/countryside_stewardship_grant_artefact_formatter"
require "formatters/countryside_stewardship_grant_indexable_formatter"
require "formatters/countryside_stewardship_grant_publication_alert_formatter"
require "markdown_attachment_processor"

class CountrysideStewardshipGrantObserversRegistry < AbstractSpecialistDocumentObserversRegistry

  private
  def format_document_as_artefact(document)
    CountrysideStewardshipGrantArtefactFormatter.new(document)
  end

  def finder_schema
    SpecialistPublisherWiring.get(:countryside_stewardship_grant_finder_schema)
  end

  def format_document_for_indexing(document)
    CountrysideStewardshipGrantIndexableFormatter.new(
      MarkdownAttachmentProcessor.new(document)
    )
  end

  def publication_alert_formatter(document)
    CountrysideStewardshipGrantPublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
