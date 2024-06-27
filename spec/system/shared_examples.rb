# frozen_string_literal: true

RSpec.shared_examples "it redirects to sign in" do
  it do
    expect(page).to have_content "You need to sign in or sign up before continuing."
  end
end

RSpec.shared_examples "it shows a 401 page" do
  it do
    expect(page).to have_content "You are not allowed to access this page."
  end
end

RSpec.shared_examples "it shows a 404 page" do
  it do
    expect(page).to have_content "The page you were looking for doesn't exist."
  end
end

RSpec.shared_examples "it shows the membership calls-to-action for" do |role|
  case role.to_sym
  when :member
    it "does not show the registration call-to-action" do
      expect(page).not_to have_content "Create your own library"
      expect(page).not_to have_link "Sign up for an account", href: new_user_registration_path
    end

    it "shows the contributor application call-to-action" do
      expect(page).to have_content "Apply to become a contributor"
      expect(page).to have_link "Apply to be a contributor", href: new_contributor_application_path
    end
  when :contributor, :admin
    it "does not show the registration call-to-action" do
      expect(page).not_to have_content "Create your own library"
      expect(page).not_to have_link "Sign up for an account", href: new_user_registration_path
    end

    it "does not show the contributor call-to-action" do
      expect(page).not_to have_content "Apply to become a contributor"
      expect(page).not_to have_link "Apply to be a contributor", href: new_user_registration_path(user: { contributor_sign_up: "1" })
      expect(page).not_to have_link "Apply to be a contributor", href: new_contributor_application_path
    end
  else
    it "shows the registration call-to-action" do
      expect(page).to have_content "Create your own library"
      expect(page).to have_link "Sign up for an account", href: new_user_registration_path
    end

    it "shows the contributor sign up call-to-action" do
      expect(page).to have_content "Apply to become a contributor"
      expect(page).to have_link "Apply to be a contributor", href: new_user_registration_path(user: { contributor_sign_up: "1" })
    end
  end
end
