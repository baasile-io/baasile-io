module PaginateConcern
  def paginate(collection)
    paginated_collection = collection.page(params[:page])

    if paginated_collection.out_of_range?
      params[:page] = 0
      paginated_collection = collection.page(0)
    end

    paginated_collection
  end
end