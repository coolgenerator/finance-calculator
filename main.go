package main

import (
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

// CalculateEAR calculates the Effective Annual Rate given the APR and number of compounding periods per year
func EARHandler(c *gin.Context) {
	fmt.Print(c.Params)
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

	ear := CalculateEAR(apr, n)
	c.JSON(http.StatusOK, gin.H{"EAR": ear})
}

// CalculateAPR calculates the Annual Percentage Rate given the EAR and number of compounding periods per year
func APRHandler(c *gin.Context) {
	fmt.Print(c.Params)
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

	apr := CalculateAPR(ear, n)
	c.JSON(http.StatusOK, gin.H{"APR": apr})
}

// CalculateTimeValue handles the request to calculate time value
func TimeValueHandler(c *gin.Context) {
	fmt.Println(c.Request.Body)
	var request struct {
		Rate     float64 `json:"rate"`
		Nper     int     `json:"nper"`
		Pmt      float64 `json:"pmt"`
		Pv       float64 `json:"pv"`
		Fv       float64 `json:"fv"`
		Type     int     `json:"type"`
		CalcType string  `json:"calcType"`
	}

	if err := c.BindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	var result float64
	var err error

	switch request.CalcType {
	case "FV":
		fmt.Print("FV")
		result = CalculateFutureValue(request.Rate, request.Nper, request.Pmt, request.Pv, request.Type == 1)
	case "PV":
		fmt.Print("PV")
		result = CalculatePresentValue(request.Rate, request.Nper, request.Pmt, request.Fv, request.Type == 1)
	case "RATE":
		fmt.Print("RATE")
		result, err = CalculateRate(request.Nper, request.Pmt, request.Pv, request.Fv, request.Type == 1, request.Rate)
	case "NPER":
		fmt.Print("NPER")
		result = CalculateNumberOfPeriods(request.Rate, request.Pmt, request.Pv, request.Fv, request.Type == 1)
	case "PMT":
		fmt.Print("PMT")
		result = CalculatePayment(request.Rate, request.Nper, request.Pv, request.Fv, request.Type == 1)
	default:
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid calculation type"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Return all the parameters along with the result
	c.JSON(http.StatusOK, gin.H{
		"rate":     request.Rate,
		"nper":     request.Nper,
		"pmt":      request.Pmt,
		"pv":       request.Pv,
		"fv":       request.Fv,
		"type":     request.Type,
		"calcType": request.CalcType,
		"result":   result,
	})
}

func TableHandler(c *gin.Context) {
	fmt.Print(c.Request.Body)
	var tableData [][]string
	if err := c.ShouldBindJSON(&tableData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	// Process the data as needed
	c.JSON(http.StatusOK, gin.H{"status": "Data received"})
}

func main() {
	r := gin.Default()

	// Configure CORS middleware options
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		AllowOriginFunc: func(origin string) bool {
			return origin == "http://localhost:3000"
		},
		MaxAge: 12 * time.Hour,
	}))

	r.GET("/calculateEAR", EARHandler)
	r.GET("/calculateAPR", APRHandler)
	r.POST("/calculateTimeValue", TimeValueHandler)
	r.POST("/table", TableHandler)
	// r.POST("/submit", func(c *gin.Context) {
	// 	var tableData [][]string
	// 	if err := c.ShouldBindJSON(&tableData); err != nil {
	// 		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
	// 		return
	// 	}
	// 	// Process the data as needed
	// 	c.JSON(http.StatusOK, gin.H{"status": "Data received"})
	// })

	// Start the server
	r.Run() // listen and serve on 0.0.0.0:8080 (for windows "localhost:8080")
}
