package main

import (
	"fmt"
	"math/rand"
	"net/http"
	"os"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	inFlight = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "http_requests_in_flight",
		Help: "A gauge of requests currently being served by the wrapped handler.",
	})
	counter = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "A counter for requests to the wrapped handler.",
		},
		[]string{"handler", "code", "method"},
	)
	duration = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "request_duration_seconds",
			Help:    "A histogram of latencies for requests.",
			Buckets: []float64{.25, .5, 1, 2.5, 5, 10},
		},
		[]string{"handler", "method"},
	)
	responseSize = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "response_size_bytes",
			Help:    "A histogram of response sizes for requests.",
			Buckets: []float64{200, 500, 900, 1500},
		},
		[]string{},
	)
)

func init() {
	prometheus.MustRegister(inFlight, counter, duration, responseSize)
}

func main() {
	helloChain := genInstrumentChain("hello", hello)

	http.Handle("/metrics", promhttp.Handler())
	http.Handle("/greet", helloChain)
	http.ListenAndServe(fmt.Sprintf(":%s", os.Getenv("PORT")), nil)
}

func genInstrumentChain(name string, handler http.HandlerFunc) http.Handler {
	return promhttp.InstrumentHandlerInFlight(inFlight,
		promhttp.InstrumentHandlerDuration(duration.MustCurryWith(prometheus.Labels{"handler": name}),
			promhttp.InstrumentHandlerCounter(counter.MustCurryWith(prometheus.Labels{"handler": name}),
				promhttp.InstrumentHandlerResponseSize(responseSize, handler),
			),
		),
	)
}

func hello(w http.ResponseWriter, _ *http.Request) {
	dur := rand.Intn(1000)
	time.Sleep(time.Duration(dur) * time.Millisecond)  // 処理を表現するためのsleep
	n := rand.Intn(4)  // エラーレスポンスを返すためのランダム値
	switch n {
	case 0:
		w.WriteHeader(http.StatusOK)
		fmt.Fprintln(w, "Hello World")
	case 1:
		w.WriteHeader(http.StatusNotFound)
		fmt.Fprintln(w, "Not Found")
	case 2:
		w.WriteHeader(http.StatusBadRequest)
		fmt.Fprintln(w, "Bad Request")
	case 3:
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintln(w, "Internal Server Error")
	}
}
