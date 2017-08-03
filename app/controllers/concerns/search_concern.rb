module SearchConcern
  def search(collection)
    if params[:q].present?
      collection = collection.look_for(params[:q])
    end

    collection
  end
end