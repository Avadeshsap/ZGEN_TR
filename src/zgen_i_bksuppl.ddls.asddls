@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZGEN_I_BKSUPPL
  as select from zgen_bksuppl
  association to parent ZGEN_I_BOOKING as _Booking on $projection.BookingUuid = _Booking.BookingUuid

  association [1] to ZGEN_I_TRAVEL as _Travel on $projection.TravelUuid = _Travel.TravelUuid

{
  key booksuppl_uuid        as BooksupplUuid,
      root_uuid             as TravelUuid,
      parent_uuid           as BookingUuid,
      booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _Booking,
      _Travel
}
