package main

import (
	"math"
	"net/http"
	"strconv"

	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

// Helper function to convert percent input to decimal
func percentToDecimal(percentStr string) (float64, error) {
	percent, err := strconv.ParseFloat(percentStr, 64)
	if err != nil {
		return 0, err
	}
	return percent / 100, nil
}

// CalculatePV handles the request to calculate present value
func CalculatePV(c *gin.Context) {
	// Extract parameters from query and convert to appropriate types
	rateStr := c.Query("rate")
	nStr := c.Query("n")
	pmtStr := c.Query("pmt")

	rate, err := percentToDecimal(rateStr) // Assume the rate is sent as a percentage like "4.5" for 4.5%
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid rate format"})
		return
	}
	n, err := strconv.Atoi(nStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid number of periods format"})
		return
	}
	pmt, err := strconv.ParseFloat(pmtStr, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid payment amount format"})
		return
	}

	// Assuming semiannual compounding
	r := rate / 2
	pv := pmt * ((1 - math.Pow(1+r, -float64(n))) / r) * (1 + r)

	// Respond with the calculated present value
	c.JSON(http.StatusOK, gin.H{"PV": pv})
}

// CalculateEAR calculates the Effective Annual Rate given the APR and number of compounding periods per year
func CalculateEAR(c *gin.Context) {
	aprStr := c.Query("apr")
	nStr := c.Query("n")

	apr, err := strconv.ParseFloat(aprStr, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid APR format"})
		return
	}

	n, err := strconv.Atoi(nStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid number of periods format"})
		return
	}

	decimalApr := apr / 100
	monthlyRate := decimalApr / float64(n)
	ear := math.Pow(1+monthlyRate, float64(n)) - 1
	ear = math.Round(ear*1000000) / 10000
	c.JSON(http.StatusOK, gin.H{"EAR": ear})
}

// CalculateAPR calculates the Annual Percentage Rate given the EAR and number of compounding periods per year
func CalculateAPR(c *gin.Context) {
	earStr := c.Query("ear")
	nStr := c.Query("n")

	ear, err := strconv.ParseFloat(earStr, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid EAR format"})
		return
	}

	n, err := strconv.Atoi(nStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid number of periods format"})
		return
	}

	decimalEar := ear / 100
	apr := float64(n) * (math.Pow(1+decimalEar, 1/float64(n)) - 1)
	apr = math.Round(apr*1000000) / 10000
	c.JSON(http.StatusOK, gin.H{"APR": apr})
}

func main() {
	r := gin.Default()

	// Configure CORS middleware options
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"http://localhost:3000"},
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		AllowOriginFunc: func(origin string) bool {
			return origin == "http://localhost:3000"
		},
		MaxAge: 12 * time.Hour,
	}))

	// Route to calculate EAR
	r.GET("/calculateEAR", CalculateEAR)
	r.GET("/calculateAPR", CalculateAPR)
	r.GET("/calculatePV", CalculatePV)
	r.POST("/submit", func(c *gin.Context) {
		var tableData [][]string
		if err := c.ShouldBindJSON(&tableData); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		// Process the data as needed
		c.JSON(http.StatusOK, gin.H{"status": "Data received"})
	})

	// Start the server
	r.Run() // listen and serve on 0.0.0.0:8080 (for windows "localhost:8080")
}
