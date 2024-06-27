# frozen_string_literal: true

module LibraryHelper
  def library_display_name(library, viewer: nil)
    return "HuMetricsHSS Published Library" if library.main?
    return "My Library" if viewer.present? && library.owner == viewer

    "#{library.owner.full_name}'s Library"
  end

  def library_icon_tag(library)
    return image_pack_tag("logo_dots.png", class: "fas", alt: "HuMetricsHHS Logo") if library.main?

    tag.i(class: "fas fa-book-open")
  end

  def sort_libraries_for_display(libraries, current_user: nil)
    libraries.sort do |first, second|
      # main library comes before everything
      next -1 if first.main?
      next 1 if second.main?

      # user's own library comes before everything else
      next -1 if first.owner_id == current_user&.id
      next 1 if second.owner_id == current_user&.id

      # otherwise sort by library owner's name
      first.owner.full_name <=> second.owner.full_name
    end
  end
end
