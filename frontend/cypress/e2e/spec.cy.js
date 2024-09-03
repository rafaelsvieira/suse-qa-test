describe('template spec', () => {
  it('passes', () => {
    const usernameInput = '[data-testid="local-login-username"]'
    const passwordInput = '[data-testid="local-login-password"] > .labeled-input > input'
    const rancherUser = Cypress.env('RANCHER_USER')
    const rancherPass = Cypress.env('RANCHER_PASSWORD')

    cy.visit('https://localhost:8443/dashboard/auth/login')
    cy.get(usernameInput).type(rancherUser)
    cy.get(usernameInput).should('have.value', rancherUser)
    cy.get(passwordInput).type(rancherPass)
    cy.get(passwordInput).should('have.value', rancherPass)
    cy.get('[data-testid="login-submit"]').click()
    cy.url({timeout:10*1000}).should('include', '/dashboard/home')
    cy.title().should('eq', 'Rancher')
  })
})