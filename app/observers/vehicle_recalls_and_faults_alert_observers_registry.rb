require "formatters/vehicle_recalls_and_faults_alert_artefact_formatter"
require "formatters/vehicle_recalls_and_faults_alert_indexable_formatter"
require "formatters/vehicle_recalls_and_faults_alert_publication_alert_formatter"
require "markdown_attachment_processor"

class VehicleRecallsAndFaultsAlertObserversRegistry < AbstractSpecialistDocumentObserversRegistry
  private

  def format_document_as_artefact(document)
    VehicleRecallsAndFaultsAlertArtefactFormatter.new(document)
  end

  def finder_schema
    SpecialistPublisherWiring.get(:vehicle_recalls_and_faults_alert_finder_schema)
  end

  def format_document_for_indexing(document)
    VehicleRecallsAndFaultsAlertIndexableFormatter.new(
      MarkdownAttachmentProcessor.new(document)
    )
  end

  def publication_alert_formatter(document)
    VehicleRecallsAndFaultsAlertPublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
