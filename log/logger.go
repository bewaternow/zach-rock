package log

import (
	"fmt"

	log "github.com/alecthomas/log4go"
)

const (
	FormatDefault = "[%D %T] [%L] (%S) %M"
	FormatShort   = "[%t %d] [%L] %M"
	FormatAbbrev  = "[%L] %M"
	FormatDev     = "[%T] [%L] %M"
)

var root log.Logger = make(log.Logger)
var outback func(level, msg string)

func LogTo(target string, levelName string, format string) {
	var writer log.LogWriter = nil

	switch target {
	case "stdout":
		w := log.NewConsoleLogWriter()
		if format != "" {
			w.SetFormat(format)
		}
		writer = w

	case "none":
		// no logging
	default:
		w := log.NewFileLogWriter(target, true)
		if format != "" {
			w.SetFormat(format)
		}
		writer = w

	}

	if writer != nil {
		var level = log.DEBUG

		switch levelName {
		case "FINEST":
			level = log.FINEST
		case "FINE":
			level = log.FINE
		case "DEBUG":
			level = log.DEBUG
		case "TRACE":
			level = log.TRACE
		case "INFO":
			level = log.INFO
		case "WARNING":
			level = log.WARNING
		case "ERROR":
			level = log.ERROR
		case "CRITICAL":
			level = log.CRITICAL
		default:
			level = log.DEBUG
		}

		root.AddFilter("log", level, writer)

	}
}

func SetOutback(out func(level, msg string)) {
	outback = out
}

type Logger interface {
	AddLogPrefix(string)
	ClearLogPrefixes()
	Debug(string, ...interface{})
	Info(string, ...interface{})
	Warn(string, ...interface{}) error
	Error(string, ...interface{}) error
}

type NullLogger struct{}

func NewNullLogger() Logger {
	return &NullLogger{}
}
func (pl *NullLogger) Debug(arg0 string, args ...interface{})       {}
func (pl *NullLogger) Info(arg0 string, args ...interface{})        {}
func (pl *NullLogger) Warn(arg0 string, args ...interface{}) error  { return nil }
func (pl *NullLogger) Error(arg0 string, args ...interface{}) error { return nil }
func (pl *NullLogger) AddLogPrefix(prefix string)                   {}
func (pl *NullLogger) ClearLogPrefixes()                            {}

type PrefixLogger struct {
	*log.Logger
	prefix string
}

func NewPrefixLogger(prefixes ...string) Logger {
	logger := &PrefixLogger{Logger: &root}

	for _, p := range prefixes {
		logger.AddLogPrefix(p)
	}

	return logger
}

func (pl *PrefixLogger) pfx(formatStr string) interface{} {
	return fmt.Sprintf("%s %s", pl.prefix, formatStr)
}

func (pl *PrefixLogger) Debug(arg0 string, args ...interface{}) {
	if outback != nil {
		outback("Debug", fmt.Sprintf(pl.pfx(arg0).(string), args...))
	}
	pl.Logger.Debug(pl.pfx(arg0), args...)
}

func (pl *PrefixLogger) Info(arg0 string, args ...interface{}) {
	if outback != nil {
		outback("Info", fmt.Sprintf(pl.pfx(arg0).(string), args...))
	}
	pl.Logger.Info(pl.pfx(arg0), args...)
}

func (pl *PrefixLogger) Warn(arg0 string, args ...interface{}) error {
	if outback != nil {
		outback("Warn", fmt.Sprintf(pl.pfx(arg0).(string), args...))
	}
	return pl.Logger.Warn(pl.pfx(arg0), args...)
}

func (pl *PrefixLogger) Error(arg0 string, args ...interface{}) error {
	if outback != nil {
		outback("Error", fmt.Sprintf(pl.pfx(arg0).(string), args...))
	}
	return pl.Logger.Error(pl.pfx(arg0), args...)
}

func (pl *PrefixLogger) AddLogPrefix(prefix string) {
	if len(pl.prefix) > 0 {
		pl.prefix += " "
	}
	pl.prefix += "[" + prefix + "]"
}

func (pl *PrefixLogger) ClearLogPrefixes() {
	pl.prefix = ""
}

type SystemLogger struct {
	NullLogger
}

func NewSystemLogger() Logger {
	return &NullLogger{}
}

// we should never really use these . . . always prefer logging through a prefix logger
func Debug(arg0 string, args ...interface{}) {
	if outback != nil {
		outback("Debug", fmt.Sprintf(arg0, args...))
	}
	root.Debug(arg0, args...)
}

func Info(arg0 string, args ...interface{}) {
	if outback != nil {
		outback("Info", fmt.Sprintf(arg0, args...))
	}
	root.Info(arg0, args...)
}

func Warn(arg0 string, args ...interface{}) error {
	if outback != nil {
		outback("Warn", fmt.Sprintf(arg0, args...))
	}
	return root.Warn(arg0, args...)
}

func Error(arg0 string, args ...interface{}) error {
	if outback != nil {
		outback("Error", fmt.Sprintf(arg0, args...))
	}
	return root.Error(arg0, args...)
}
