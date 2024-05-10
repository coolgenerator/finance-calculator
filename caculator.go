package main

import (
	"errors"
	"math"
	"strconv"
)

func PercentToDecimal(percentStr string) (float64, error) {
	percent, err := strconv.ParseFloat(percentStr, 64)
	if err != nil {
		return 0, err
	}
	return percent / 100, nil
}

// CalculateFutureValue calculates the future value of a series of payments.
func CalculateFutureValue(interestRate float64, numberOfPeriods int, payment float64, presentValue float64, paymentAtBeginning bool) float64 {
	if interestRate == 0 {
		return -(presentValue + float64(numberOfPeriods)*payment)
	}
	interestRate /= 100
	rateFactor := math.Pow(1+interestRate, float64(numberOfPeriods))
	typeMultiplier := 0.0
	if paymentAtBeginning {
		typeMultiplier = 1
	}
	return -(presentValue*rateFactor + payment*(1+interestRate*typeMultiplier)*(rateFactor-1)/interestRate)
}

// CalculatePayment calculates the payment amount for an annuity based on constant payments and a constant interest rate.
func CalculatePayment(interestRate float64, numberOfPeriods int, presentValue float64, futureValue float64, paymentAtBeginning bool) float64 {
	if interestRate == 0 {
		return -(futureValue + presentValue) / float64(numberOfPeriods)
	}
	interestRate /= 100
	rateFactor := math.Pow(1+interestRate, float64(numberOfPeriods))
	typeMultiplier := 0.0
	if paymentAtBeginning {
		typeMultiplier = 1
	}
	return -(futureValue + presentValue*rateFactor) / ((1 + interestRate*typeMultiplier) * (rateFactor - 1) / interestRate)
}

// CalculatePresentValue calculates the present value of an annuity.
func CalculatePresentValue(interestRate float64, numberOfPeriods int, payment float64, futureValue float64, paymentAtBeginning bool) float64 {
	if interestRate == 0 {
		return -(payment*float64(numberOfPeriods) + futureValue)
	}
	interestRate /= 100
	rateFactor := math.Pow(1+interestRate, float64(numberOfPeriods))
	typeMultiplier := 0.0
	if paymentAtBeginning {
		typeMultiplier = 1
	}
	return -(payment*(1+interestRate*typeMultiplier)*(rateFactor-1)/interestRate + futureValue) / rateFactor
}

// CalculateRate attempts to calculate the interest rate per period of an annuity using a numerical approach.
func CalculateRate(numberOfPeriods int, payment float64, presentValue float64, futureValue float64, paymentAtBeginning bool, guess float64) (float64, error) {
	rate := guess
	for i := 0; i < 100; i++ {
		f := CalculateFutureValue(rate, numberOfPeriods, payment, presentValue, paymentAtBeginning) - futureValue
		df := (CalculateFutureValue(rate+0.00001, numberOfPeriods, payment, presentValue, paymentAtBeginning) - futureValue) - f
		rate -= f / df
		if math.Abs(f) < 1e-6 {
			return rate, nil
		}
	}
	return 0, errors.New("rate calculation did not converge")
}

// CalculateNumberOfPeriods determines the total number of periods for an investment based on periodic, constant payments and a constant interest rate.
func CalculateNumberOfPeriods(interestRate float64, payment float64, presentValue float64, futureValue float64, paymentAtBeginning bool) float64 {
	if interestRate == 0 {
		return -(futureValue + presentValue) / payment
	}
	interestRate /= 100
	rateFactor := math.Pow(1+interestRate, 1)
	typeMultiplier := 0.0
	if paymentAtBeginning {
		typeMultiplier = 1
	}
	return math.Log((payment+typeMultiplier*payment*interestRate)/(payment+typeMultiplier*payment*interestRate-futureValue*interestRate)/presentValue) / math.Log(rateFactor)
}

// CalculateEAR calculates the Effective Annual Rate
func CalculateEAR(apr float64, n int) float64 {
	decimalApr := apr / 100
	monthlyRate := decimalApr / float64(n)
	ear := math.Pow(1+monthlyRate, float64(n)) - 1
	return math.Round(ear*1000000) / 10000
}

// CalculateAPR calculates the Annual Percentage Rate
func CalculateAPR(ear float64, n int) float64 {
	decimalEar := ear / 100
	apr := float64(n) * (math.Pow(1+decimalEar, 1/float64(n)) - 1)
	return math.Round(apr*1000000) / 10000
}
