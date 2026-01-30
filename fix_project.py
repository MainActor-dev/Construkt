import os
import uuid
import sys

# Configuration
PROJECT_PATH = "Demo/Construkt.xcodeproj/project.pbxproj"
SOURCES_ROOT = "Sources" # Relative to where we run the script (project root)
GROUP_NAME = "Sources"
TARGET_NAME = "Construkt"

# Helper to generate Xcode-like IDs
def generate_id():
    return uuid.uuid4().hex[:24].upper()

def main():
    if not os.path.exists(PROJECT_PATH):
        print(f"Error: Project file not found at {PROJECT_PATH}")
        sys.exit(1)

    with open(PROJECT_PATH, 'r') as f:
        lines = f.readlines()

    # Define section boundaries
    sections = {}
    current_section = None
    section_start_index = -1
    objects_start_index = -1
    objects_end_index = -1

    for i, line in enumerate(lines):
        if "objects = {" in line:
            objects_start_index = i
        if "/* Begin" in line and "section */" in line:
            current_section = line.split("Begin ")[1].split(" section")[0]
            section_start_index = i
        elif "/* End" in line and "section */" in line and current_section:
            sections[current_section] = (section_start_index, i)
            current_section = None
    
    # Locate end of objects section (usually near end of file)
    for i in range(len(lines) - 1, -1, -1):
        if "};" in lines[i] and "rootObject =" in lines[i+1]:
             # Approximate location if strictly formatted, but easier to search for last brace before rootObject
             pass
    
    # Collect files to add
    files_to_add = []
    if os.path.exists(SOURCES_ROOT):
        for root, dirs, files in os.walk(SOURCES_ROOT):
            for file in files:
                if file.endswith(".swift"):
                    full_path = os.path.join(root, file)
                    # We need path relative to the project.pbxproj location (Demo/)
                    # If CWD is root, and file is Sources/Construkt/Core/Builder.swift
                    # and pbxproj is Demo/Construkt.xcodeproj/project.pbxproj
                    # relative path is ../Sources/Construkt/Core/Builder.swift
                    rel_path = os.path.join("..", full_path)
                    files_to_add.append(rel_path)
    else:
        print(f"Error: Sources root {SOURCES_ROOT} not found.")
        sys.exit(1)
    
    files_to_add.sort()
    print(f"Found {len(files_to_add)} swift files to add.")

    if not files_to_add:
        print("No files found. Exiting.")
        return

    # Generate IDs
    file_ids = {} # path -> (file_ref_id, build_file_id)
    for path in files_to_add:
        file_ids[path] = (generate_id(), generate_id())

    # 1. Prepare Content
    build_file_lines = []
    file_ref_lines = []
    
    for path, (fr_id, bf_id) in file_ids.items():
        name = os.path.basename(path)
        build_file_lines.append(f"\t\t{bf_id} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {fr_id} /* {name} */; }};\n")
        file_ref_lines.append(f"\t\t{fr_id} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"{path}\"; sourceTree = \"<group>\"; }};\n")

    # 2. Insert into PBXBuildFile
    new_lines = lines[:]
    
    if "PBXBuildFile" in sections:
        bf_start, bf_end = sections["PBXBuildFile"]
        new_lines[bf_end:bf_end] = build_file_lines
    else:
        # Create section if missing
        print("Creating PBXBuildFile section...")
        section_content = [
            "\n/* Begin PBXBuildFile section */\n"
        ] + build_file_lines + [
            "/* End PBXBuildFile section */\n"
        ]
        # Insert at top of objects
        if objects_start_index != -1:
            new_lines[objects_start_index+1:objects_start_index+1] = section_content
        else:
            print("Error: Could not find objects start.")
            sys.exit(1)
        # Re-parse lines indices if we wanted to be perfect, but we just need to shift offsets for subsequent ops

    # Re-calculate sections just to be safe or use offsets. 
    # Simplest is to just re-read or track the offset manually.
    offset = len(build_file_lines) if "PBXBuildFile" in sections else len(section_content)

    # 3. Insert into PBXFileReference
    # Recalculate section start because of previous insertion
    # (Actually simpler to just parse again conceptually, but expensive? No, small file)
    # Let's just track offset. 
    
    # We need to find PBXFileReference in new_lines now.
    # To be lazy/safe, let's just find the marker again.
    fr_marker_index = -1
    for i, line in enumerate(new_lines):
        if "/* Begin PBXFileReference section */" in line:
            fr_marker_index = i
            break
            
    if fr_marker_index != -1:
        # Find end
        fr_end_index = -1
        for i in range(fr_marker_index, len(new_lines)):
             if "/* End PBXFileReference section */" in line: # ERROR: variable line is from outer loop not inner check? No, 'line' isn't valid here.
                 pass 
        # Correct approach:
        for i in range(fr_marker_index, len(new_lines)):
            if "/* End PBXFileReference section */" in new_lines[i]:
                fr_end_index = i
                break
        
        new_lines[fr_end_index:fr_end_index] = file_ref_lines
    else:
        print("Error: PBXFileReference section missing. This is unexpected for a valid project.")
        # Create it? 
        sys.exit(1)

    # 4. Create proper PBXGroup
    sources_group_id = generate_id()
    children_list = ",\n\t\t\t\t".join([f"{ids[0]} /* {os.path.basename(p)} */" for p, ids in file_ids.items()])
    sources_group_block = f"""\t\t{sources_group_id} /* {GROUP_NAME} */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{children_list}
\t\t\t);
\t\t\tname = {GROUP_NAME};
\t\t\tsourceTree = "<group>";
\t\t}};\n"""
    
    # Insert group
    # Find PBXGroup section end
    grp_end_index = -1
    for i in range(len(new_lines)):
        if "/* End PBXGroup section */" in new_lines[i]:
            grp_end_index = i
            break
            
    if grp_end_index != -1:
        new_lines[grp_end_index:grp_end_index] = [sources_group_block]
    
    # 5. Add Group to Main Group
    # Find mainGroup ID in the PBXProject section
    main_group_id = None
    for line in new_lines:
        if "mainGroup =" in line:
             main_group_id = line.split(" = ")[1].strip().replace(";", "")
             break
    
    if main_group_id:
        print(f"Main Group ID: {main_group_id}")
        # Find the group definition
        for i, line in enumerate(new_lines):
            if f"{main_group_id} =" in line:
                for j in range(i, len(new_lines)):
                    if "children = (" in new_lines[j]:
                        new_lines.insert(j+1, f"\t\t\t\t{sources_group_id} /* {GROUP_NAME} */,\n")
                        break
                break

    # 6. Add to PBXSourcesBuildPhase
    # Find Sources build phase
    for i, line in enumerate(new_lines):
        if "isa = PBXSourcesBuildPhase;" in line:
            for j in range(i, len(new_lines)):
                if "files = (" in new_lines[j]:
                    build_files_entries = [f"\t\t\t\t{ids[1]} /* {os.path.basename(p)} in Sources */,\n" for p, ids in file_ids.items()]
                    new_lines[j+1:j+1] = build_files_entries
                    break
            break

    # Write back
    with open(PROJECT_PATH, 'w') as f:
        f.writelines(new_lines)
    
    print("Project file updated successfully.")

if __name__ == "__main__":
    main()
