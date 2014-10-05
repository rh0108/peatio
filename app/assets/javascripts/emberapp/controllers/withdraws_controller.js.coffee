Peatio.WithdrawsController = Ember.ArrayController.extend
  init: ->
    controller = @
    @._super()
    Peatio.set('withdraws-controller', @)
    $.subscribe('withdraw:create', ->
      record = controller.get('model')[0].account().withdraws().pop()
      controller.get('withdraws').insertAt(0, record)
      $.subscribe('withdraw:update', (event, data)->
        update_records = _.filter(controller.get('withdraws'), (r) ->
          r.id == data.id)
        if update_records.length > 0
          update_records[0].set('aasm_state', data.attributes.aasm_state)
          if data.attributes.aasm_state != "submitting" and data.attributes.aasm_state != "submitted"
            $('#cancel_link').remove()

      )
      if controller.get('withdraws').length > 3
        setTimeout(->
          controller.get('withdraws').popObject()
        , 1000)
    )

  btc: (->
    @model[0].currency == "btc"
  ).property('@each')

  cny: (->
    @model[0].currency == "cny"
  ).property('@each')

  btsx: (->
    @model[0].currency == "btsx"
  ).property('@each')

  pts: (->
    @model[0].currency == "pts"
  ).property('@each')

  dog: (->
    @model[0].currency == "dog"
  ).property('@each')

  withdraws: (->
    @model[0].account().topWithdraws()
  ).property('@each')

  balance: (->
    @model[0].account().balance
  ).property('@each')

  fsources: (->
    FundSource.findAllBy('currency', @model[0].currency)
  ).property('@each')

  name: (->
    current_user.name
  ).property('')

  app_activated: (->
    current_user.app_activated
  ).property('')

  sms_activated: (->
    current_user.sms_activated
  ).property('')

  app_and_sms_activated: (->
    current_user.app_activated and current_user.sms_activated
  ).property('')

  actions: {
    submitBtcWithdraw: ->
      fund_source = $(event.target).find('#fund_source').val()
      sum = $(event.target).find('#withdraw_sum').val()
      currency = @model[0].currency
      account = @model[0].account()
      data = { withdraw: { account_id: account.id, member_id: current_user.id, currency: currency, sum: sum,  fund_source: fund_source }}

      if current_user.app_activated or current_user.sms_activated
        type = $('.two_factor_auth_type').val()
        otp = $("#two_factor_otp").val()
        data['two_factor'] = { type: type, otp: otp }


      $('#withdraw_btc_submit').attr('disabled', 'disabled')
      $.ajax({
        url: '/withdraws/satoshis',
        method: 'post',
        data: data
      }).done(->
        $('#withdraw_btc_submit').removeAttr('disabled')
      )

    withdrawAll: ->
      $('#withdraw_sum').val(@get('balance'))

    submitCnyWithdraw: ->
      fund_source = $(event.target).find('#fund_source').val()
      sum = $(event.target).find('#withdraw_sum').val()
      currency = @model[0].currency
      account = @model[0].account()
      data = { withdraw: { account_id: account.id, member_id: current_user.id, currency: currency, sum: sum,  fund_source: fund_source }}

      if current_user.app_activated or current_user.sms_activated
        type = $('.two_factor_auth_type').val()
        otp = $("#two_factor_otp").val()
        data['two_factor'] = { type: type, otp: otp }

      $('#withdraw_btc_submit').attr('disabled', 'disabled')
      $.ajax({
        url: "/withdraws/#{@model[0].key}s",
        method: 'post',
        data: data
      }).done(->
        $('#withdraw_cny_submit').removeAttr('disabled')
      )

    cancelDeposit: ->
      record_id = event.target.dataset.id
      url = "/withdraws/#{@model[0].key}s/#{record_id}"
      $.ajax({
        url: url
        method: 'DELETE'
      })

  }
