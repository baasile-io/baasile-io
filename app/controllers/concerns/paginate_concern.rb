module PaginateConcern
  def paginate(collection, per_page: nil)
    paginated_collection = collection.page(params[:page])

    if per_page
      paginated_collection = paginated_collection.per(per_page)
    end

    if paginated_collection.out_of_range?
      params[:page] = 0
      paginated_collection = collection.page(0)
    end

    paginated_collection
  end
end