package backend_test

import (
	"bytes"
	"crypto/tls"
	"fmt"
	"net/http"
	"os"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("Rancher login", func() {
	const loginURL = "https://localhost:8443/v3-public/localProviders/local?action=login"

	Context("When get login successed", func() {
		It("should return the correct response", func() {
			tr := &http.Transport{
				TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
			}
			requestBody := fmt.Sprintf(`{"description": "UI session","responseType": "cookie","username": "%s","password": "%s"}`, os.Getenv("RANCHER_USER"), os.Getenv("RANCHER_PASSWORD"))
			request, _ := http.NewRequest("POST", loginURL, bytes.NewBuffer([]byte(requestBody)))
			request.Header.Set("Content-Type", "application/json")

			client := &http.Client{Transport: tr}
			response, err := client.Do(request)
			Expect(err).NotTo(HaveOccurred())
			Expect(response.StatusCode).To(Equal(http.StatusOK))
		})
	})

	Context("When get login failed", func() {
		It("should return an error in the response", func() {
			tr := &http.Transport{
				TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
			}
			requestBody := `{"description": "UI session","responseType": "cookie","username": "test","password": "test"}`
			request, _ := http.NewRequest("POST", loginURL, bytes.NewBuffer([]byte(requestBody)))
			request.Header.Set("Content-Type", "application/json")

			client := &http.Client{Transport: tr}
			response, err := client.Do(request)
			Expect(err).NotTo(HaveOccurred())
			Expect(response.StatusCode).To(Equal(http.StatusUnauthorized))
		})
	})
})
