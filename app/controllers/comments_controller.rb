class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    comment = Comment.new(comment_params)
    comment.user = current_user
    if comment.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.comment'))
    end
    redirect_to :back, fallback_url: url_for(comment.commentable)
  end

  def hide
    comment = Comment.find(params[:id])
    if comment.update_attributes(deleted: true)
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.comment'))
    end
    redirect_to :back, fallback_url: url_for(comment.commentable)
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :commentable_type, :commentable_id)
  end
end