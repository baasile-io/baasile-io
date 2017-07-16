class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    commentable = params[:comment][:commentable_type].constantize
                    .find(params[:comment][:commentable_id])

    comment = ::Services::Comments::Create.new(comment_params,
                                               commentable: commentable,
                                               user: current_user).call

    if comment.persisted?
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.comment'))
    else
      flash[:error] = comment.errors.full_messages.join(', ')
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