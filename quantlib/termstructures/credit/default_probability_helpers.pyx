#
# Copyright (C) 2011, Enthought Inc
# Copyright (C) 2011, Patrick Henaff
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the license for more details.
#

from cython.operator cimport dereference as deref

from quantlib.handle cimport shared_ptr, Handle

cimport quantlib.termstructures.credit._credit_helpers as _ci
cimport quantlib.termstructures._yield_term_structure as _yts
from quantlib.time._period cimport Frequency
from quantlib.time._schedule cimport Rule
from quantlib.time._calendar cimport BusinessDayConvention


from quantlib.time.date cimport Period, date_from_qldate, Date
cimport quantlib.time._date as _date
from quantlib.time.calendar cimport Calendar
from quantlib.time.daycounter cimport DayCounter
from quantlib.termstructures.yields.yield_term_structure cimport YieldTermStructure
cimport quantlib._quote as _qt

cdef class CdsHelper:
    """Base default-probability bootstrap helper

    Parameters
    ----------
    tenor :  :class:`~quantlib.time.date.Period`
        CDS tenor.
    frequency :  Frequency
        Coupon frequency.
    settlementDays : Integer
        The number of days from today's date
        to the start of the protection period.
    paymentConvention : BusinessDayConvention
        The payment convention applied to
        coupons schedules, settlement dates
        and protection period calculations.

    """

    @property
    def latest_date(self):
        cdef _date.Date d = self._thisptr.get().latestDate()
        return date_from_qldate(d)

    @property
    def implied_quote(self):
        return self._thisptr.get().impliedQuote()

    @property
    def quote(self):
        cdef shared_ptr[_qt.Quote] quote_ptr = \
            shared_ptr[_qt.Quote](self._thisptr.get().quote().currentLink())
        return quote_ptr.get().value()

cdef class SpreadCdsHelper(CdsHelper):
    """Spread-quoted CDS hazard rate bootstrap helper.

    Parameters
    ----------
    running_spread : float
        Running spread of the CDS.
    tenor :  :class:`~quantlib.time.date.Period`
        CDS tenor.
    settlementDays : int
        The number of days from today's date
        to the start of the protection period.
    calendar: :class:`~quantlib.time.calendar.Calendar`
    frequency :  Frequency
        Coupon frequency.
    payment_convention : int
        The payment convention applied to
        coupons schedules, settlement dates
        and protection period calculations.
    date_generation_rule : int
    daycounter : :class:`~quantlib.time.daycounter.DayCounter`
    recovery_rate : float
    discount_curve : :class:`~quantlib.termstructures.yields.yield_term_structure.YieldTermStructure`
    settles_accrual : bool, optional
    pays_at_default_time : bool, optional

    """

    def __init__(self, double running_spread, Period tenor, int settlement_days,
                 Calendar calendar, int frequency,
                 int paymentConvention, int date_generation_rule,
                 DayCounter daycounter, double recovery_rate,
                 YieldTermStructure discount_curve, settles_accrual=True,
                 pays_at_default_time=True):
        """
        """

        cdef Handle[_yts.YieldTermStructure] yts = \
            deref(discount_curve._thisptr.get())


        self._thisptr = new shared_ptr[_ci.CdsHelper](\
            new _ci.SpreadCdsHelper(running_spread, deref(tenor._thisptr.get()),
                settlement_days, deref(calendar._thisptr), <Frequency>frequency,
                <BusinessDayConvention>paymentConvention, <Rule>date_generation_rule,
                deref(daycounter._thisptr),
                recovery_rate, yts, settles_accrual,
                pays_at_default_time)
        )
