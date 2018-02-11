module Services
  module Comments
    class Create

      def initialize(comment_params, commentable:, user:)
        @comment_params = comment_params
        @commentable = commentable
        @user = user
      end

      def call
        create
      end

      private

        attr_reader :comment_params, :commentable, :user

        def create
          Comment.new(comment_params).tap do |comment|
            comment.commentable = commentable
            comment.user = user
            comment.save
          end
        end

    end
  end
end
