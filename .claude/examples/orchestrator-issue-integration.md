# Orchestrator + Issue File Integration Example

## User Request
```
"I want to build a SaaS application for small businesses to manage their customer relationships. It should have contact management, email integration, and basic reporting features."
```

## Orchestrator Execution Flow

### Step 1: Issue File Creation
**Orchestrator** creates: `.claude/issues/saas-crm-small-business.md`

```bash
# Orchestrator command execution
@orchestrator "Build SaaS CRM for small businesses with contact management, email integration, and reporting"
```

**Generated Issue File** (initial state):
```markdown
# Issue: SaaS CRM for Small Businesses

## Original Request
> **Date Created**: 2024-01-15  
> **Orchestrator**: orchestrator-exec-001  
> **Status**: 🔄 In Progress

I want to build a SaaS application for small businesses to manage their customer relationships. It should have contact management, email integration, and basic reporting features.

---

## Research Phase (by researcher agent)
> **Status**: 🔄 In Progress  
> **Agent**: researcher  
> **Started**: [timestamp]  
> **Completed**: [timestamp]

[To be filled by researcher agent]

## Requirements Analysis Phase (by fn-reqs agent)
> **Status**: ⏸️ Pending  
> **Agent**: fn-reqs  
> **Started**: [timestamp]  
> **Completed**: [timestamp]

[To be filled by fn-reqs agent]

## Architecture Design Phase (by architect agent)
> **Status**: ⏸️ Pending  
> **Agent**: architect  
> **Started**: [timestamp]  
> **Completed**: [timestamp]

[To be filled by architect agent]
```

### Step 2: Sequential Agent Execution

#### Phase 1: Researcher Agent
```javascript
// Orchestrator invokes researcher
const researchResult = await Task({
  description: "Research SaaS CRM market",
  prompt: `
    Read the issue file: .claude/issues/saas-crm-small-business.md
    
    Conduct comprehensive research for the SaaS CRM project described in the "Original Request" section.
    Update your designated section with findings and mark your phase as completed.
    
    Focus on:
    - Small business CRM market analysis
    - Contact management solutions landscape
    - Email integration technologies
    - Reporting and analytics tools
    - Technology stack recommendations
  `,
  subagent_type: "general-purpose"
});
```

**Researcher Updates Issue File**:
```markdown
## Research Phase (by researcher agent)
> **Status**: ✅ Completed  
> **Agent**: researcher  
> **Started**: 2024-01-15T10:00:00Z  
> **Completed**: 2024-01-15T11:30:00Z

### Market Research Findings
- Small business CRM market size: $12.1B (2024)
- Top competitors: HubSpot, Salesforce Essentials, Pipedrive, Zoho CRM
- Key differentiation opportunities: simplified UI, industry-specific features
- Average pricing: $25-50/user/month for small business segment

### Technology Landscape Analysis
- **Backend**: Node.js/Express (35%), Python/Django (28%), Ruby/Rails (22%)
- **Frontend**: React (42%), Vue.js (31%), Angular (18%)
- **Database**: PostgreSQL (preferred for relational data), MongoDB (for flexibility)
- **Email Integration**: SendGrid, Mailgun, Amazon SES
- **Authentication**: Auth0, Firebase Auth, custom JWT

### Implementation Feasibility Assessment
- **Development Timeline**: 4-6 months for MVP
- **Team Requirements**: 2-3 full-stack developers, 1 UI/UX designer
- **Technical Complexity**: Medium (standard CRUD + integrations)
- **Key Challenges**: Email deliverability, data migration, scaling

### Key Recommendations for Requirements Phase
- **High-Priority Features**: Contact CRUD, basic email templates, simple reporting dashboard
- **Technical Constraints**: Must support 10,000+ contacts per organization
- **User Personas**: Small business owners (primary), sales staff (secondary)
- **Competitive Differentiation**: Focus on ease of setup and industry templates
```

#### Phase 2: fn-reqs Agent
```javascript
// Orchestrator invokes fn-reqs
const requirementsResult = await Task({
  description: "Analyze CRM requirements",
  prompt: `
    Read the issue file: .claude/issues/saas-crm-small-business.md
    
    Review the completed "Research Phase" findings and the "Original Request".
    Structure the functional requirements based on the research insights.
    Update your designated section and mark your phase as completed.
    
    Ask any clarifying questions needed for requirement validation.
  `,
  subagent_type: "fn-reqs"
});
```

**fn-reqs Updates Issue File**:
```markdown
## Requirements Analysis Phase (by fn-reqs agent)
> **Status**: ✅ Completed  
> **Agent**: fn-reqs  
> **Started**: 2024-01-15T12:00:00Z  
> **Completed**: 2024-01-15T14:15:00Z

### Functional Requirements

#### FR-001: Contact Management
- **Description**: Users can create, read, update, and delete customer contacts
- **Priority**: High
- **Complexity**: Simple
- **Dependencies**: User authentication (FR-006)
- **Acceptance Criteria**:
  - [ ] Add contact with name, email, phone, company, notes
  - [ ] Search and filter contacts by various fields
  - [ ] Import contacts from CSV file
  - [ ] Export contact list to CSV/Excel

#### FR-002: Email Integration
- **Description**: Send emails to contacts and track interactions
- **Priority**: High  
- **Complexity**: Medium
- **Dependencies**: Contact Management (FR-001)
- **Acceptance Criteria**:
  - [ ] Send individual emails to contacts
  - [ ] Create and save email templates
  - [ ] Track email opens and clicks
  - [ ] View email history for each contact

### Feature Priority Matrix
| Feature | Business Value | Technical Complexity | Priority | Implementation Phase |
|---------|----------------|---------------------|----------|---------------------|
| Contact CRUD | High | Low | P0 | Phase 1 |
| Email Templates | High | Medium | P0 | Phase 1 |
| Basic Reporting | Medium | Low | P1 | Phase 2 |
| Email Tracking | Medium | High | P1 | Phase 2 |
| Advanced Search | Low | Medium | P2 | Phase 3 |
```

#### Phase 3: Architect Agent
```javascript
// Orchestrator invokes architect
const architectureResult = await Task({
  description: "Design CRM architecture",
  prompt: `
    Read the issue file: .claude/issues/saas-crm-small-business.md
    
    Review the completed "Research Phase" and "Requirements Analysis Phase" sections.
    Design a comprehensive system architecture that addresses all requirements.
    Update your designated section and complete the project summary.
  `,
  subagent_type: "architect"
});
```

**Architect Updates Issue File**:
```markdown
## Architecture Design Phase (by architect agent)
> **Status**: ✅ Completed  
> **Agent**: architect  
> **Started**: 2024-01-15T15:00:00Z  
> **Completed**: 2024-01-15T17:45:00Z

### System Architecture Overview
Multi-tenant SaaS application with RESTful API backend, React frontend, and PostgreSQL database. Microservices approach for email processing and reporting.

### Technology Stack Recommendations

#### Backend
- **Language**: Node.js 18+ - Aligns with research findings (35% market adoption)
- **Framework**: Express.js with TypeScript - Rapid development, strong ecosystem
- **Database**: PostgreSQL 15 - Relational data model suits CRM requirements
- **Key Libraries**: Prisma ORM, bcrypt, jsonwebtoken, nodemailer

#### Frontend  
- **Framework**: React 18 with TypeScript - Market leader (42% adoption)
- **State Management**: Zustand - Lightweight, less complex than Redux
- **UI Library**: Tailwind CSS + Headless UI - Rapid prototyping
- **Build Tools**: Vite - Fast development experience

### Implementation Roadmap

#### Phase 1: Core Infrastructure (Weeks 1-4)
- [ ] Database schema with multi-tenancy support
- [ ] JWT-based authentication system
- [ ] Basic CRUD API for contacts
- [ ] React app with authentication flow

#### Phase 2: Core Features (Weeks 5-8)  
- [ ] Contact management UI (add, edit, delete, search)
- [ ] Email template system
- [ ] Basic email sending functionality
- [ ] Simple reporting dashboard

## Project Summary & Next Steps

### Overall Project Status
- **Research**: ✅ Completed - Market analysis and technology evaluation done
- **Requirements**: ✅ Completed - 6 functional requirements defined with priorities  
- **Architecture**: ✅ Completed - Full system design with implementation roadmap

### Recommended Next Actions
1. **Immediate (Next 1-2 weeks)**:
   - [ ] Set up development environment (Node.js, PostgreSQL, React)
   - [ ] Create initial database schema with Prisma
   - [ ] Implement basic authentication system

2. **Short-term (Next month)**:
   - [ ] Develop contact CRUD operations
   - [ ] Build React components for contact management
   - [ ] Integrate email sending capabilities
```

### Step 4: Final Orchestrator Summary

```javascript
// Orchestrator provides final summary to user
return {
  status: "completed",
  issueFile: ".claude/issues/saas-crm-small-business.md",
  phases: {
    research: "✅ Completed - Market analysis done, technology stack identified",
    requirements: "✅ Completed - 6 functional requirements defined with priorities",
    architecture: "✅ Completed - Full system architecture with 12-week roadmap"
  },
  nextSteps: [
    "Review complete project specification in issue file",
    "Set up development environment per architecture recommendations", 
    "Begin Phase 1 implementation with core infrastructure"
  ],
  estimatedTimeline: "4-6 months for full MVP",
  recommendedTeam: "2-3 full-stack developers, 1 UI/UX designer"
}
```

## Benefits of This Integration

### 1. **Persistent Documentation**
- Complete project history in single file
- All decisions and rationale preserved
- Easy reference for development team

### 2. **Seamless Information Flow**
- No context loss between agents
- Each agent builds on previous work
- Full traceability of requirements to research

### 3. **Structured Handoffs**
- Clear completion criteria for each phase
- Status tracking prevents premature progression
- Quality gates enforced through deliverables

### 4. **Stakeholder Transparency**
- Single source of truth for project status
- Clear visibility into decision-making process
- Easy review and approval workflow

### 5. **Scalable Process**
- Template ensures consistency across projects
- Reusable pattern for future development initiatives
- Clear separation of concerns between agents