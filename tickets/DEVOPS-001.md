# DEVOPS-001 — Understand the Application You Inherited

You have joined the NovaCart project, and the team cannot make safe deployment decisions until someone understands how the application actually behaves.

Before any infrastructure work begins, inspect and run the application so you can document the runtime facts another engineer would need before deployment.

Start with the application handover README and the backend entrypoint so you can discover the runtime details from the source itself.

## Deliverable

Create:

`docs/application-discovery.md`

Document:

* Application components
* Languages and frameworks
* Startup/build commands
* Listening ports
* Application dependencies
* Configuration and environment variables
* Secrets or sensitive configuration
* Persistence requirements
* Database dependencies
* Health and readiness behavior
* Service-to-service communication
* Logging behavior
* External dependencies, if any
* Runtime assumptions
* Risks or missing information
* Questions you would ask the development team before production deployment

## Acceptance Criteria

Another DevOps engineer should be able to read your document and understand:

* what components need to be deployed
* how they communicate
* what configuration they require
* what data must persist
* how application health can be verified
* what information is still missing before production deployment

They should not need to read the entire application source code to understand the runtime requirements.
