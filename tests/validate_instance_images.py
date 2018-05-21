#!/usr/bin/env python3
from pathlib import Path

import yaml

from flex_version import FlexVersion


class ReleaseDep(object):
	def __init__(self, dep_desc):
		self.type = dep_desc['type']
		self.max_version = dep_desc['max-version']
		self.min_version = dep_desc['min-version']


class ReleaseInfo(object):
	# All metainfo of versioned instances:
	# {instance: {version: ReleaseInfo}}
	__instance_releases = dict()

	def __init__(self, instance_name, release_version, is_final, dependencies=None):
		self.instance_name = instance_name
		self.release_version = release_version
		self.is_final = is_final
		if dependencies:
			self.dependencies = [ReleaseDep(i) for i in dependencies]
		else:
			self.dependencies = list()

	@classmethod
	def add_release(cls, instance_name, release_desc):
		release_version = release_desc['release-version']
		is_final = release_desc['final']
		image_version = release_desc['image-version']
		dep_desc = release_desc['dependencies']

		release = ReleaseInfo(instance_name, release_version, is_final, dep_desc)

		if instance_name not in cls.__instance_releases:
			cls.__instance_releases[instance_name] = dict()
		if release.release_version not in cls.__instance_releases[instance_name]:
			cls.__instance_releases[instance_name][release.release_version] = dict()
		else:
			assert False, 'Duplicated release version {} for {}' \
				.format(release.release_version, instance_name)
		cls.__instance_releases[instance_name][release.release_version] = release

		return release

	@classmethod
	def all_instance_releases(cls):
		return cls.__instance_releases


def scan_instances(root_dir):
	"""
	Scan all instances directories
	"""
	rp = Path(root_dir)
	instances = [x for x in rp.iterdir() if x.is_dir()]
	for instance in instances:
		instance = instance.name
		inspath = Path(rp.joinpath(instance))
		versions = [x for x in inspath.iterdir() if x.is_dir()]
		for version in versions:
			version = version.name
			vpath = inspath.joinpath(version)
			imgpath = vpath.joinpath('images.yaml')
			assert Path(imgpath).exists(), \
				'File images.yaml absent for {}/{}'.format(instance, version)
			images = yaml.load(open(imgpath))

			# Validate images meta info
			validate_versioned_image(images, instance, version)


def validate_versioned_image(images, instance_name, instance_version):
	"""
	Validate the meta info of images defined for each instance
	"""
	print('Validating versioned {}, {}'.format(instance_name, instance_version))
	assert images['instance-type'].lower() == instance_name.lower()
	assert images['major-version'] == instance_version
	assert 'images'  in images
	assert 'releases' in images
	assert 'min-tdc-version' in images
	assert 'hot-fix-ranges' in images

	# Collect all releases of instances
	releases = dict()
	for r in images.get('releases', list()):
		release_info = ReleaseInfo.add_release(instance_name, r)
		releases[release_info.release_version] = release_info

	# Validate hot-fix range: each defined release should be in a hot-fix range
	hot_fixes = images.get('hot-fix-ranges', list())
	for rv in releases:
		found = False
		for fix_range in hot_fixes:
			if FlexVersion.in_range(rv, minv=fix_range['min'], maxv=fix_range['max']):
				found = True
		assert found, 'Release version {} of {} not in a valid hot-fix range'\
			.format(rv, instance_name)

	# Validate dependence min-max range: min <= max
	for release_info in releases.values():
		for dep in release_info.dependencies:
			res = FlexVersion.compares(dep.min_version, dep.max_version)
			assert res <= 0, 'Invalid min-max range [min: {}, max: {}] for version {} of {}'\
				.format(dep.min_version, dep.max_version, release_info.release_version, instance_name)


def _find_a_ranged_version(instance_name, minv, maxv):
	"""
	Given a version range, check if a valid version is defined in the range.
	"""
	all_instance_releases = ReleaseInfo.all_instance_releases()
	versions = all_instance_releases.get(instance_name, dict())
	found = False
	for v, release_info in versions.items():
		found = FlexVersion.in_range(v, minv, maxv)
		if found:
			break
	return found


def validate_dependence_versions():
	"""
	Each dependence should have at least a version defined.
	"""
	print('Total {} instances defined'.format(len(ReleaseInfo.all_instance_releases())))
	all_instance_releases = ReleaseInfo.all_instance_releases()

	# Validate dependencies: each dependence should have a valid
	# version as in defined range
	for instance_name, versions in all_instance_releases.items():
		for instance_version, release_info in versions.items():
			print('Validating dependence of {} version {}'.format(release_info.instance_name, instance_version))
			dependencies = release_info.dependencies
			for dep in dependencies:
				dep_type = dep.type
				minv = dep.min_version
				maxv = dep.max_version

				assert dep_type in all_instance_releases,\
					"No dependence found {} for version {} of {}"\
						.format(dep_type, instance_version, instance_name)

				found = _find_a_ranged_version(dep_type, minv=minv, maxv=maxv)
				assert found, "No valid version defined for {} with max: {}, min: {}"\
					.format(dep_type, maxv, minv)


if __name__ == '__main__':
	proj_root = Path(__file__).parent.parent

	scan_instances(proj_root.joinpath('instances'))
	
	validate_dependence_versions()
