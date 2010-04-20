class BidsController < ApplicationController
  before_filter :login_required, :only => [:new,:edit,:create,:update,:destroy]
  before_filter :setup

  # POST /bids
  # POST /bids.xml
  def create
    @bid = @req.bids.new(params[:bid])
    @bid.person = current_person

    respond_to do |format|
      if @bid.save
        flash[:success] = t('success_bid_created') 
        format.html { redirect_to req_path(@req) }
        #format.xml  { render :xml => @bid, :status => :created, :location => @bid }
      else
        flash[:error] = t('error_creating_bid') 
        format.html { redirect_to req_path(@req) }
        #format.xml  { render :xml => @bid.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /bids/1
  # PUT /bids/1.xml
  def update
    @bid = Bid.find(params[:id])
    case params[:aasm_event]
    when 'accept'
      if current_person?(@bid.req.person)
        @bid.accept!
        flash[:notice] = t('notice_bid_accepted')
      end
    when 'commit'
      if current_person?(@bid.person)
        @bid.commit!
        flash[:notice] = t('notice_bid_committed')
      end
    when 'complete'
      if current_person?(@bid.person)
        @bid.complete!
        flash[:notice] = t('notice_bid_completed')
      end
    when 'pay'
      if current_person?(@bid.req.person)
        @bid.pay!
        flash[:notice] = t('notice_bid_approved')
      end
    else
      logger.warn "Error.  Invalid bid event: #{params[:aasm_event]}"
      flash[:error] = t('notice_bid_invalid')
    end
    redirect_to @req
  end

  # DELETE /bids/1
  # DELETE /bids/1.xml
  def destroy
    @bid = Bid.find(params[:id])
    @bid.destroy

    respond_to do |format|
      flash[:success] = t('notice_bid_removed')
      format.html { redirect_to req_url(@req) }
      #format.xml  { head :ok }
    end
  end

  private

  def setup
    @req = Req.find(params[:req_id])
    @body = "req"
  end
end