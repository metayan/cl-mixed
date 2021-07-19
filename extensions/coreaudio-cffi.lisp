#|
 This file is a part of cl-mixed
 (c) 2017 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(defpackage #:org.shirakumo.fraf.mixed.coreaudio.cffi
  (:use #:cl)
  (:export
   #:audio-unit
   #:audio-toolbox
   #:kAudioUnitType_Output
   #:kAudioUnitSubType_DefaultOutput
   #:kAudioUnitManufacturer_Apple
   #:kAudioFormatLinearPCM
   #:no-err
   #:os-type
   #:os-status
   #:audio-component
   #:component-instance
   #:component-result
   #:audio-component-instance
   #:audio-unit
   #:audio-unit-property-id
   #:audio-unit-scope
   #:audio-unit-element
   #:audio-format-id
   #:audio-format-flags
   #:render-action-flags
   #:component-instance-record
   #:component-instance-record-data
   #:audio-component-description
   #:audio-component-description-component-type
   #:audio-component-description-component-sub-type
   #:audio-component-description-component-manufacturer
   #:audio-component-description-component-flags
   #:audio-component-description-component-flags-mask
   #:audio-stream-basic-description
   #:audio-stream-basic-description-sample-rate
   #:audio-stream-basic-description-format-id
   #:audio-stream-basic-description-format-flags
   #:audio-stream-basic-description-bytes-per-packet
   #:audio-stream-basic-description-frames-per-packet
   #:audio-stream-basic-description-bytes-per-frame
   #:audio-stream-basic-description-channels-per-frame
   #:audio-stream-basic-description-bits-per-channel
   #:audio-stream-basic-description-reserved
   #:au-render-callback-struct
   #:au-render-callback-struct-input-proc
   #:au-render-callback-struct-input-proc-ref-con
   #:smpte-time
   #:smpte-time-subframes
   #:smpte-time-subframe-dicisor
   #:smpte-time-counter
   #:smpte-time-type
   #:smpte-time-flags
   #:smpte-time-hours
   #:smpte-time-minutes
   #:smpte-time-seconds
   #:smpte-time-frames
   #:audio-time-stamp
   #:audio-time-stamp-sample-time
   #:audio-time-stamp-host-time
   #:audio-time-stamp-rate-scalar
   #:audio-time-stamp-word-clock-time
   #:audio-time-stamp-smpte-time
   #:audio-time-stamp-flags
   #:audio-time-stamp-reserved
   #:audio-buffer
   #:audio-buffer-number-channels
   #:audio-buffer-data-byte-size
   #:audio-buffer-data
   #:audio-buffer-list
   #:audio-buffer-list-number-buffers
   #:audio-buffer-list-buffers
   #:audio-component-find-next
   #:audio-component-instance-new
   #:audio-component-instance-dispose
   #:audio-unit-set-property
   #:audio-unit-get-property
   #:audio-unit-initialize
   #:audio-unit-uninitialize
   #:audio-output-unit-start
   #:audio-output-unit-stop))
(in-package #:org.shirakumo.fraf.mixed.coreaudio.cffi)

;; https://github.com/rweichler/coreaudio-examples/blob/master/CH07_AUGraphSineWave/main.c
(cffi:define-foreign-library audio-unit
  (:darwin (:framework "AudioUnit")))

(cffi:define-foreign-library audio-toolbox
  (:darwin (:framework "AudioToolbox")))

;; Constants
(alexandria:define-constant kAudioUnitType_Output "auou" :test 'equal)
(alexandria:define-constant kAudioUnitSubType_DefaultOutput "def " :test 'equal)
(alexandria:define-constant kAudioUnitManufacturer_Apple "appl" :test 'equal)
(alexandria:define-constant kAudioFormatLinearPCM "lpcm" :test 'equal)
(defconstant no-err 0)

;; Types
(cffi:define-foreign-type os-type () ()
  (:actual-type :int32))

(cffi:define-parse-method os-type ()
  (make-instance 'os-type))

(defmethod cffi:translate-to-foreign (string (type os-type))
  (let ((int 0))
    (dotimes (i 4 int)
      (setf (ldb (byte 8 (* (- 3 i) 8)) int) (char-code (aref string i))))))

(defmethod cffi:translate-from-foreign (integer (type os-type))
  (let ((string (make-string 4)))
    (dotimes (i 4 string)
      (setf (aref string i) (code-char (ldb (byte 8 (* (- 3 i) 8)) integer))))))

(defmethod cffi:free-translated-object (pointer (type os-type) param)
  (declare (ignore param))
  (cffi:foreign-string-free pointer))

(cffi:defctype os-status :int32)
(cffi:defctype audio-component :pointer)
(cffi:defctype component-instance :pointer)
(cffi:defctype component-result :int32)
(cffi:defctype audio-component-instance :pointer)
(cffi:defctype audio-unit component-instance)
(cffi:defctype audio-unit-property-id :uint32)
(cffi:defctype audio-unit-element :uint32)
(cffi:defctype audio-format-id os-type)

;; Enums
(cffi:defcenum render-action-flags
  (:pre-render #.(ash 1 2))
  (:post-render #.(ash 1 3))
  (:output-is-silence #.(ash 1 4))
  (:preflight #.(ash 1 5))
  (:render #.(ash 1 6))
  (:complete #.(ash 1 7))
  (:post-render-error #.(ash 1 8))
  (:do-not-check-render-args #.(ash 1 9)))

(cffi:defcenum (audio-property :uint32)
  (:stream-format 8)
  (:render-callback 23)
  (:samples 49))

(cffi:defcenum (audio-scope :uint32)
  (:global 0)
  (:in 1)
  (:out 2))

(cffi:defbitfield (audio-format :uint32)
  (:native 0)
  (:float #x1)
  (:signed #x4)
  (:packed #x8))

;; Structs
(cffi:defcstruct (component-instance-record :conc-name component-instance-record-)
  (data :long :count 1))

(cffi:defcstruct (audio-component-description :conc-name audio-component-description-)
  (component-type os-type)
  (component-sub-type os-type)
  (component-manufacturer os-type)
  (component-flags :uint32)
  (component-flags-mask :uint32))

(cffi:defcstruct (audio-stream-basic-description :conc-name audio-stream-basic-description-)
  (sample-rate :double)
  (format-id audio-format-id)
  (format-flags audio-format)
  (bytes-per-packet :uint32)
  (frames-per-packet :uint32)
  (bytes-per-frame :uint32)
  (channels-per-frame :uint32)
  (bits-per-channel :uint32)
  (reserved :uint32))

(cffi:defcstruct (au-render-callback-struct :conc-name au-render-callback-struct-)
  (input-proc :pointer)
  (input-proc-ref-con :pointer))

(cffi:defcstruct (smpte-time :conc-name smpte-time-)
  (subframes :int16)
  (subframe-divisor :int16)
  (counter :uint32)
  (type :uint32)
  (flags :uint32)
  (hours :int16)
  (minutes :int16)
  (seconds :int16)
  (frames :int16))

(cffi:defcstruct (audio-time-stamp :conc-name audio-time-stamp-)
  (sample-time :double)
  (host-time :uint64)
  (rate-scalar :double)
  (word-clock-time :uint64)
  (smpte-time (:struct smpte-time))
  (flags :uint32)
  (reserved :uint32))

(cffi:defcstruct (audio-buffer :conc-name audio-buffer-)
  (number-channels :uint32)
  (data-byte-size :uint32)
  (data :pointer))

(cffi:defcstruct (audio-buffer-list :conc-name audio-buffer-list-)
  (number-buffers :uint32)
  (buffers (:struct audio-buffer) :count 1))

;; Funcs
(cffi:defcfun (audio-component-find-next "AudioComponentFindNext") audio-component
  (component audio-component)
  (description :pointer))

(cffi:defcfun (audio-component-instance-new "AudioComponentInstanceNew") os-status
  (component audio-component)
  (output :pointer))

(cffi:defcfun (audio-component-instance-dispose "AudioComponentInstanceDispose") os-status
  (component audio-component-instance))

(cffi:defcfun (audio-unit-set-property "AudioUnitSetProperty") os-status
  (unit audio-unit)
  (property audio-property)
  (scope audio-scope)
  (element audio-unit-element)
  (data :pointer)
  (size :uint32))

(cffi:defcfun (audio-unit-get-property "AudioUnitGetProperty") os-status
  (unit audio-unit)
  (property audio-property)
  (scope audio-scope)
  (element audio-unit-element)
  (data :pointer)
  (size :pointer))

(cffi:defcfun (audio-unit-initialize "AudioUnitInitialize") os-status
  (unit audio-unit))

(cffi:defcfun (audio-unit-uninitialize "AudioUnitUninitialize") os-status
  (unit audio-unit))

(cffi:defcfun (audio-output-unit-start "AudioOutputUnitStart") os-status
  (unit audio-unit))

(cffi:defcfun (audio-output-unit-stop "AudioOutputUnitStop") os-status
  (unit audio-unit))
