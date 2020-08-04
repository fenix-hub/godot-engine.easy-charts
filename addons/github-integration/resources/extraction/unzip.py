import glob,zipfile,shutil,os,sys,tarfile

archive = sys.argv[1]
destination = sys.argv[2]

if archive.endswith('.zip'):
    with zipfile.ZipFile(archive) as zip:
        for zip_info in zip.infolist():
            if zip_info.filename == zip.infolist()[0].filename :
                continue
            zip_info.filename = zip_info.filename.replace(zip.infolist()[0].filename,'')
            zip_info.filename.replace(zip.infolist()[0].filename,'')
elif archive.endswith('.tar.gz'):
    tar = tarfile.open(archive)
    for member in tar.getmembers():
        if member.name == tar.getmembers()[0].name:
            continue
        member.name = member.name.replace(tar.getmembers()[0].name+'/','')
        tar.extract(member, destination)
