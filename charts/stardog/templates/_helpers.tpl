{{- define "stardog.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "stardog.fullname" -}}
{{- if .Values.fullnameOverride  -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "stardog" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "zkservers" -}}
{{- $zk := dict "servers" (list) -}}
{{- $namespace := .Release.Namespace -}}
{{- $name := .Release.Name -}}
{{- range int .Values.zookeeper.replicaCount | until -}}
{{- $noop := printf "%s-zookeeper-%d.%s-zookeeper-headless.%s:2181" $name . $name $namespace | append $zk.servers | set $zk "servers" -}}
{{- end -}}
{{- join "," $zk.servers -}}
{{- end -}}

{{- define "imagePullSecret" -}}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.stardog.image.registry (printf "%s:%s" .Values.stardog.image.username .Values.stardog.image.password | b64enc) | b64enc }}
{{- end -}}

{{- define "launchpadimagePullSecret" -}}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.launchpad.image.registry (printf "%s:%s" .Values.launchpad.image.username .Values.launchpad.image.password | b64enc) | b64enc }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "launchpad.serviceAccountName" -}}
{{- if .Values.launchpad.serviceAccount.create }}
{{- default (include "stardog.fullname" .) .Values.launchpad.serviceAccount.name }}
{{- else -}}
{{- default "default" .Values.launchpad.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create stardog tls
*/}}
{{- define "stardog.protocol" -}}
{{- if .Values.stardog.tls.enabled -}}
{{- printf "%s" "https" }}
{{- else -}}
{{- printf "%s" "http" }}
{{- end -}}
{{- end -}}

{{/*
Create launchpad tls
*/}}

{{- define "launchpad.protocol" -}}
{{- if .Values.launchpad.tls.enabled -}}
{{- printf "%s" "https" }}
{{- else -}}
{{- printf "%s" "http" }}
{{- end -}}
{{- end -}}

{{/*
Create launchpad host
*/}}
{{- define "launchpad.host" }}
{{- if .Values.launchpad.ingress.enabled }}
{{- printf "launchpad.%s" .Values.launchpad.ingress.url }}
{{- else }}
{{- if or (not .Values.launchpad.env.BASE_URL) (eq (len .Values.launchpad.env.BASE_URL) 0) }} 
{{- printf "%s-launchpad:%d" (include "stardog.fullname" .) (.Values.launchpad.service.port |int ) }}
{{- else }}
{{- printf "%s" .Values.launchpad.env.BASE_URL }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create stardog host
*/}}
{{- define "stardog.host" }}
{{- if .Values.stardog.ingress.enabled }}
{{- printf "sparql.%s" .Values.stardog.ingress.url }}
{{- else }}
{{- printf "%s:%d" (include "stardog.fullname" .) (.Values.stardog.ports.server |int )}}
{{- end }}
{{- end }}

{{/*
Merge a list of values that contains template after rendering them.
Usage:
{{ include "tplvalues.merge" ( dict "values" (list .Values.path.to.the.Value1 .Values.path.to.the.Value2) "context" $ ) }}
*/}}
{{- define "tplvalues.merge" -}}
{{- $dst := dict -}}
{{- range .values -}}
{{- $dst = include "common.tplvalues.render" (dict "value" . "context" $.context "scope" $.scope) | fromYaml | merge $dst -}}
{{- end -}}
{{ $dst | toYaml }}
{{- end -}}

{{/*
Renders a value that contains template perhaps with scope if the scope is present.
Usage:
{{ include "common.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $ ) }}
{{ include "common.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $ "scope" $app ) }}
*/}}
{{- define "tplvalues.render" -}}
{{- $value := typeIs "string" .value | ternary .value (.value | toYaml) }}
{{- if contains "{{" (toJson .value) }}
  {{- if .scope }}
      {{- tpl (cat "{{- with $.RelativeScope -}}" $value "{{- end }}") (merge (dict "RelativeScope" .scope) .context) }}
  {{- else }}
    {{- tpl $value .context }}
  {{- end }}
{{- else }}
    {{- $value }}
{{- end }}
{{- end -}}