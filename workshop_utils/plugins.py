"""
Graceful 429 & Quota Resilience Plugin for Google ADK Agents.
Based on the official Google Cloud Learning Services (CLS) Lab Architect standards.

Intercepts Vertex AI / Gemini API 429 RESOURCE_EXHAUSTED errors during workshops
and provides realistic fallback responses to prevent blocking learners.
"""

from typing import Union, Dict
from google.adk.plugins import BasePlugin
from google.adk.models import LlmResponse
from google.genai import types

class Graceful429Plugin(BasePlugin):
    """Intercepts local failures to Vertex AI and handles quota exhaustion gracefully."""

    def __init__(self, name: str = "graceful_429_plugin", fallback_text: Union[str, Dict[str, str]] = None):
        super().__init__(name=name)
        if fallback_text is None:
            self.fallback_text = {
                "due diligence": (
                    "**[Resposta de Contingência - Quota de API Excedida (429)]**\n\n"
                    "### Relatório Sintético de Due Diligence Contratual\n\n"
                    "**1. Identificação das Partes:** Nexus Tecnologia Ltda. e Sócios Administradores.\n"
                    "**2. Objeto Social:** Desenvolvimento de software sob encomenda e serviços de TI.\n"
                    "**3. Estrutura Societária e Capital:** R$ 100.000,00 integralizados.\n"
                    "**4. Cláusulas Críticas Auditadas:**\n"
                    "- **Administração:** Assinatura conjunta para atos que ultrapassem R$ 50.000,00.\n"
                    "- **Cessão e Transferência de Quotas:** Direito de preferência estabelecido em 30 dias.\n"
                    "- **Não Concorrência (Non-Compete):** Vigente por 24 meses após a saída de qualquer sócio.\n"
                    "**5. Parecer de Conformidade:** CONFORME com apontamento de atenção para alçadas de administração."
                ),
                "default": (
                    "**[Aviso de Quota]:** O limite temporário de requisições da API foi atingido (429 RESOURCE_EXHAUSTED). "
                    "Para manter o andamento do laboratório sem interrupções, o agente retornou esta resposta segura pré-armazenada. "
                    "Você pode prosseguir normalmente com as próximas etapas."
                )
            }
        else:
            self.fallback_text = fallback_text

    def _get_fallback_text(self, request_contents) -> str:
        """Determines the correct fallback text by scanning the prompt for keywords."""
        if isinstance(self.fallback_text, str):
            return self.fallback_text

        req_str = str(request_contents).lower()
        best_keyword = None
        best_index = -1

        for keyword, response in self.fallback_text.items():
            if keyword == "default":
                continue
            idx = req_str.rfind(keyword.lower())
            if idx > best_index:
                best_index = idx
                best_keyword = keyword

        if best_keyword:
            return self.fallback_text[best_keyword]

        return self.fallback_text.get(
            "default",
            "Limite de taxa temporariamente atingido. Prossiga para a próxima etapa do workshop."
        )

    async def on_model_error(
        self,
        *,
        agent,
        model,
        input,
        error: Exception
    ) -> Union[LlmResponse, None]:
        """Standard ADK hook for handling model-level exceptions."""
        err_msg = str(error)
        if "RESOURCE_EXHAUSTED" in err_msg or "429" in err_msg or "503" in err_msg:
            print(f"\n[Graceful429Plugin] Interceptado erro de cota ({err_msg[:60]}...). Retornando fallback seguro para {self.name}.")
            fallback = self._get_fallback_text(input)
            return LlmResponse(
                content=types.Content(
                    role="model",
                    parts=[types.Part.from_text(text=fallback)]
                )
            )
        return None

    def apply_429_interceptor(self, agent):
        """Surgically wraps the agent's model pipeline to catch 429s during async streams."""
        targets = []
        if hasattr(agent, 'sub_agents') and agent.sub_agents:
            for sub_agent in agent.sub_agents:
                if hasattr(sub_agent, 'model'):
                    targets.append(sub_agent.model)
        else:
            if hasattr(agent, 'model'):
                targets.append(agent.model)

        for target in targets:
            if not hasattr(target, 'generate_content_async'):
                continue
            original_method = getattr(target, 'generate_content_async')

            async def wrapped_429_failover(*args, **kwargs):
                try:
                    async for result in original_method(*args, **kwargs):
                        yield result
                except Exception as e:
                    err_str = str(e)
                    if "RESOURCE_EXHAUSTED" in err_str or "429" in err_str or "503" in err_str:
                        print(f"\n[Graceful429Plugin] Interceptado 429 no stream assíncrono. Retornando fallback.")
                        request_contents = args[0] if len(args) > 0 else kwargs
                        fallback = self._get_fallback_text(request_contents)
                        yield LlmResponse(
                            content=types.Content(
                                role="model",
                                parts=[types.Part.from_text(text=fallback)]
                            )
                        )
                    else:
                        raise

            object.__setattr__(target, 'generate_content_async', wrapped_429_failover)
            print(f"[Graceful429Plugin] Interceptor de cota 429 anexado com sucesso ao modelo do agente.")
