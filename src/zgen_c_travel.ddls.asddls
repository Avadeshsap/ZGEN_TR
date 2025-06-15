@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption For Travel'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #CONSUMPTION
@Metadata.allowExtensions: true
define root view entity ZGEN_C_TRAVEL
provider contract transactional_query
  as projection on ZGEN_I_TRAVEL
{
  key TravelUuid,
      TravelId,
      AgencyId,
      CustomerId,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      Description,
      OverallStatus,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _Booking: redirected to composition child ZGEN_C_BOOKING
}
