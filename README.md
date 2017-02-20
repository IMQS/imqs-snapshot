# imqs-snapshot
Scripts for taking a snapshot of a server and deploying it on another server/machine or building a fresh server/machine from imports.

## Dependencies
### 7-Zip
should be able to call `7z` from terminal

## Usage
All relevent services will be stoped before snapshot export/import/build, and started after snapshot export/import/build.

### Export
`export.rb <server_name>`
The argument `<server_name>` will be used to make a folder with `server_name` as its name in `T:\\IMQS8_Data\Snapshots`.
The `server_name` folder will contain compressed dumps of the current server's postgress database, mongo database, binarys and configs.

### Import
`import.rb <server_name> [nobin]`
The argument `server_name` must correspond to a folder name in `T:\\IMQS8_Data\Snapshots`.
The optional argument `nobin` will instruct the importer to not import the binarys.
The importer will only import that which it can find.

### Build
`build.rb <server_name>`
The argument `server_name` must correspond to a folder name in `T:\\IMQS8_Data\Snapshots`.
A fresh postgress database will be built from the contents of the `Imports` folder located in the `server_name` folder.