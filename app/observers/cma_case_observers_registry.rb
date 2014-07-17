class CmaCaseObserversRegistry
  def creation
    [
      panopticon_exporter,
    ]
  end

  def update
    [
      panopticon_exporter,
    ]
  end

  def publication
    [
      content_api_exporter,
      finder_api_exporter,
      panopticon_exporter,
      rummager_exporter,
    ]
  end

  def withdrawal
    [
      content_api_withdrawer,
      finder_api_withdrawer,
      panopticon_exporter,
      rummager_withdrawer,
    ]
  end

private
  def panopticon_exporter
    SpecialistPublisherWiring.get(:cma_case_panopticon_registerer)
  end

  def content_api_exporter
    SpecialistPublisherWiring.get(:cma_case_content_api_exporter)
  end

  def finder_api_exporter
    SpecialistPublisherWiring.get(:finder_api_notifier)
  end

  def rummager_exporter
    SpecialistPublisherWiring.get(:cma_case_rummager_indexer)
  end

  def rummager_withdrawer
    SpecialistPublisherWiring.get(:cma_case_rummager_deleter)
  end

  def finder_api_withdrawer
    SpecialistPublisherWiring.get(:finder_api_withdrawer)
  end

  def content_api_withdrawer
    SpecialistPublisherWiring.get(:specialist_document_content_api_withdrawer)
  end
end