module Private
  class TicketsController < BaseController
    def index
      @tickets = current_user.tickets
    end

    def new
      @ticket = Ticket.new
    end

    def create
      ticket = current_user.tickets.create(ticket_params)
      if ticket.save
        flash[:notice] = I18n.t('private.tickets.ticket_create_succ')
        redirect_to tickets_path
      else
        flash[:alert] = I18n.t('private.tickets.ticket_create_fail')
        render :new
      end
    end

    def show
      @ticket = current_user.tickets.find(params[:id])
      @comments = @ticket.comments
      @comment = Comment.new
    end

    private

    def ticket_params
      params.required(:ticket).permit(:title, :content)
    end
  end
end
