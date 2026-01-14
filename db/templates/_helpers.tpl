
{{- define "label.name" -}}
app.local.io/name: {{ .Values.labels.name }}
{{- end }}
{{- define "label.component" -}}
app.local.io/component: {{ .Values.labels.component }}
{{- end }}
{{- define "label.instance" -}}
app.local.io/instance: {{ .Values.labels.instance }}
{{- end }}
{{- define "matchLabel" -}}
{{- end }}
{{- define "labels" -}}
app.local.io/name: {{ .Values.labels.name }}
app.local.io/component: {{ .Values.labels.component }}
app.local.io/instance: {{ .Values.labels.instance }}
{{- end }}