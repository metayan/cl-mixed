#|
 This file is a part of cl-mixed
 (c) 2017 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.fraf.mixed)

(defclass drain (virtual)
  ((program-name :initform "Mixed" :initarg :program-name :accessor program-name)
   (pack :initform NIL :reader pack)))

(defmethod initialize-instance :after ((drain drain) &key pack)
  (setf (pack drain) pack))

(defmethod (setf pack) (thing (drain drain))
  (etypecase thing
    ((or null pack) (setf (slot-value drain 'pack) thing))
    (packer (setf (pack drain) (pack thing)))))

(defmethod info ((drain drain))
  (list :name (string (class-name (class-of drain)))
        :description "Output drain."
        :flags ()
        :min-inputs 0
        :max-inputs 0
        :outputs 0
        :fields ()))

(defmethod output-field ((field (eql :pack)) (location (eql 0)) (drain drain))
  (pack drain))

(defmethod (setf output-field) ((value pack) (field (eql :pack)) (location (eql 0)) (drain drain))
  (setf (pack drain) value))

(defmethod (setf output-field) ((value null) (field (eql :pack)) (location (eql 0)) (drain drain))
  (setf (pack drain) value))

(defmethod output ((location (eql 0)) (drain drain))
  (pack drain))

(defgeneric channel-order (drain))

(defmethod channel-order ((drain drain))
  *default-channel-order*)

(defmethod framesize ((drain drain))
  (framesize (pack drain)))

(defmethod samplerate ((drain drain))
  (samplerate (pack drain)))

(defmethod encoding ((drain drain))
  (encoding (pack drain)))

(defmethod channels ((drain drain))
  (channels (pack drain)))

(defclass device-drain (drain)
  ())

(defgeneric list-devices (device-drain))
(defgeneric device (device-drain))
(defgeneric (setf device) (device device-drain))

(defmethod print-object ((drain device-drain) stream)
  (print-unreadable-object (drain stream :type T :identity T)
    (format stream "~a" (device drain))))
