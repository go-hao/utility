package r

import (
	"fmt"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

type R struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data"`
}

func New() *R {
	return &R{
		Code:    0,
		Message: "",
		Data:    nil,
	}
}

func (r *R) SetCode(code int) {
	r.Code = code
}

func (r *R) SetMessage(message string) {
	r.Message = strings.ToLower(message)
}

func (r *R) SetData(data interface{}) {
	r.Data = data
}

func (r *R) SetCodeAndMessageWithCode(code int) {
	r.SetCode(code)
	r.SetMessage(http.StatusText(code))
}

func (r *R) SetMessageWithError(err error) {
	message := fmt.Sprintf("[error] %s", err.Error())
	r.SetMessage(message)
}

func (r *R) JSON(c *gin.Context) {
	c.JSON(r.Code, r)
}

func (r *R) AbortWithStatusJSON(c *gin.Context) {
	c.AbortWithStatusJSON(r.Code, r)
}
