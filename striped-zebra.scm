; author: Thomas Hintz
; email: t@thintz.com
; license: bsd

; Copyright (c) 2012-2013, Thomas Hintz
; All rights reserved.

; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
;     * Redistributions of source code must retain the above copyright
;       notice, this list of conditions and the following disclaimer.
;     * Redistributions in binary form must reproduce the above copyright
;       notice, this list of conditions and the following disclaimer in the
;       documentation and/or other materials provided with the distribution.
;     * Neither the name of the <organization> nor the
;       names of its contributors may be used to endorse or promote products
;       derived from this software without specific prior written permission.

; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
; DISCLAIMED. IN NO EVENT SHALL THOMAS HINTZ BE LIABLE FOR ANY
; DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
; (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
; 	    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
; 	    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
; 	    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
; 	    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

(module striped-zebra
  (;; params
   api-endpoint api-version default-username

   ;; procs
   send-stripe-request charge add-customer
   )

(import scheme chicken)
(use http-client intarweb uri-common json)

(define ++ string-append)

(define api-endpoint (make-parameter "https://api.stripe.com/"))
(define api-version (make-parameter "/v1/"))
(define default-username (make-parameter ""))

(define (send-stripe-request #!key (method 'GET) endpoint (body #f) (username (default-username)))
  (with-input-from-request
   (make-request method: method
		 uri: (uri-reference (++ (api-endpoint) (api-version) endpoint))
		 headers: (headers `((authorization . (#(basic ((username . ,username))))))))
   body
   json-read))

(define (charge amount #!key (card-token #f) (customer #f) (username (default-username)) (description ""))
  (send-stripe-request method: 'POST endpoint: "charges" username: username
		       body: `((amount . ,amount)
			       (description . ,description)
			       (currency . "usd")
			       (card . ,card-token)
			       (customer . ,customer))))

(define (add-customer card-token #!key (description "") (email "") (username (default-username)) (plan ""))
  (send-stripe-request method: 'POST endpoint: "customers" username: username
		       body: `((card . ,card-token)
			       (email . ,email)
			       (plan . ,plan)
			       (description . ,description))))

)
