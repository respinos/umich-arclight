workspace {
  model {
    researcher = person "Researcher" "A person interested in materials held by an archive."
    operator = person "App Operator" "Administrative staff who conduct system operations."
    manager = person "Data Manager" "Staff who manage the archival metadata."

    requestSystem = softwareSystem "Material Request System" "Allows patrons to request materials or copies from a given archive. Commonly implemented by a partner with Aeon." "External System"
    arclight = softwareSystem "ArcLight" {
      webapp = container "Web App" "Offers browse and search features across materials housed in many archival repositories." "Ruby/Rails/Blacklight"
      search = container "Search Index" "Offers structured and free text searches of finding aids (EADs/archival descriptions)." "Solr"
      database = container "Database" "Holds historical/analytical data about search activity." "PostgreSQL" "Database"
      jobqueue = container "Job Queue" "Holds jobs to be processed asynchronously." "Redis/Resque"
      workers = container "Background Workers" "Process data jobs like indexing EADs." "Ruby/Resque"
      console = container "Admin Console" "Offers management functionality to system operators." "Rake/Rails Console"
      data = container "Archives Data" "Structured file storage for preparing and importing EADs." "Enterprise Storage" "Filesystem"
    }

    researcher -> arclight "Navigates to" "HTTPS/HTML"
    researcher -> webapp "Navigates to" "HTTPS/HTML"
    operator -> console "Runs administrative tasks" "SSH"
    manager -> data "Curates archives data in" "NFS"

    console -> jobqueue "Enqueues jobs in" "Redis"
    console -> search "Reads from and writes to" "HTTPS"

    webapp -> search "Reads from" "HTTPS"
    webapp -> database "Records search activity in" "pgsql gem"

    workers -> jobqueue "Fetch jobs from" "Redis"
    workers -> search "Add documents to" "HTTPS"

    console -> data "Reads from and writes to" "NFS"
    workers -> data "Read from" "NFS"

    arclight -> requestSystem "Directs material requests to" "HTTPS"
    webapp -> requestSystem "Directs material requests to" "HTTPS"
  }

  views {
    systemContext arclight {
      include *
    }

    container arclight {
      include *
    }


    theme default
    styles {
      element "External System" {
        background #999999
      }

      element "Database" {
        shape Cylinder
      }

      element "Browser Application" {
        shape WebBrowser
      }

      element "Filesystem" {
        shape Folder
      }
    }
  }
}
