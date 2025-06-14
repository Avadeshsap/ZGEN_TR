@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Suppl Consumtion View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION
define view entity ZGEN_C_BKSUPPL
  as projection on ZGEN_I_BKSUPPL
{
  key BooksupplUuid,
      TravelUuid,
      BookingUuid,
      BookingSupplementId,
      SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,
      LocalLastChangedAt,
      /* Associations */
      _Booking: redirected to parent ZGEN_C_BOOKING,
      _Travel: redirected to ZGEN_C_TRAVEL
}
